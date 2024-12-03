/*
Defines the VoiceAnalyzer class, which interfaces with external
libraries and the local DSP module to perform analysis on the
microphone stream.
*/

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:sound_library/sound_library.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'vocal_stats.dart';
import 'formants.dart';

class VoiceAnalyzer {
  AudioRecorder? recorder;
  RecordConfig recorderConfig =
      const RecordConfig(encoder: AudioEncoder.pcm16bits);
  Queue<Uint8List> buffer = Queue<Uint8List>();
  bool isPlaying = false, isForwardingSnapshots = false;
  Duration playDelay = const Duration();
  PitchDetector pitchDetector = PitchDetector();

  VoiceAnalyzer() {
    try {
      recorder = AudioRecorder();
    } on UnimplementedError {
      recorder = null;
    }

    // Check validity of recorder
    recorder?.hasPermission().then((hasPermission) {
      if (hasPermission) {
        recorder?.startStream(recorderConfig).then((recorderStream) {
          recorderStream.listen((data) {
            // print('Got packet');
            // Don't let more than 128 packets pile up
            while (buffer.length > 128) {
              buffer.removeFirst();
            }
            // Add this data packet to the end
            buffer.add(data);
          });
        });
      } else {
        throw Exception('Failed to get permission');
      }
    });
  }

  void dispose() {
    endPlayStreamWithDelay();
  }

  // Yields a single VocalStats instance based on the most
  // recent data.
  Future<VocalStats> getSnapshot() async {
    VocalStats out = VocalStats(const [-1.0, -1.0, -1.0, -1.0]);

    // Avoid using empty buffer or buffer that is already in use
    if (isPlaying || buffer.isEmpty) {
      return out;
    }
    final Uint8List data = buffer.first;

    // Extract pitch (easy part)
    // print('Getting pitch...');
    final result = await pitchDetector.getPitchFromIntBuffer(data);
    out.averagePitch = result.pitch;

    if (out.averagePitch == -1.0) {
      // Some sort of error case, IDK
      out.resonanceMeasure = -1.0;
      return out;
    }

    // Some preprocessing
    const step = 16;
    List<double> processedData = List<double>.empty(growable: true);

    for (int i = 0; i < data.length; i += step) {
      double avg = 0.0;
      for (int j = i; j < i + step; j++) {
        avg += data[j];
      }
      avg /= step;

      processedData.add(avg);
    }

    // Extract formants (hard part)
    // print('Processing packet of length ${processedData.length}');
    // print('Getting F1...');
    final f1 = await getF1(
        processedData, out.averagePitch, recorderConfig.sampleRate.toDouble());
    out.resonanceMeasure = f1;
    // print('Got it!');

    // Return extracted statistics object
    return out;
  }

  // Play to the speakers directly from the microphone stream, with the given
  // delay in seconds. This runs until the corresponding end function is called,
  // or the object is destroyed. Only handles seconds and milliseconds.
  // This also cancels any existing subscriptions.
  void beginPlayStreamWithDelay(double seconds) async {
    if (isPlaying) {
      endPlayStreamWithDelay();
    } else if (isForwardingSnapshots) {
      endSnapshots();
    } else if (recorder == null) {
      return;
    }
    isPlaying = true;
    playDelay = Duration(
        seconds: seconds.floor(), milliseconds: (seconds * 1000).floor());

    Timer.periodic(playDelay, (timer) async {
      if (!isPlaying) {
        timer.cancel();
        return;
      } else if (buffer.isEmpty) {
        return;
      }

      final toPlay = buffer.removeFirst();
      SoundPlayer.playFromBytes(toPlay);
    });
  }

  // Stop playing audio.
  void endPlayStreamWithDelay() {
    recorder?.cancel();
    isPlaying = false;
  }

  // Register a callback to receive snapshots periodically upon
  // microphone update. This also cancels any existing
  // subscriptions.
  void beginSnapshots(double seconds, callback) {
    if (isPlaying) {
      endPlayStreamWithDelay();
    } else if (isForwardingSnapshots) {
      endSnapshots();
    } else if (recorder == null) {
      return;
    }

    isForwardingSnapshots = true;
    playDelay = Duration(
        seconds: seconds.floor(), milliseconds: (seconds * 1000).floor());

    Timer.periodic(playDelay, (timer) {
      if (!isForwardingSnapshots) {
        timer.cancel();
        return;
      } else if (buffer.isEmpty) {
        return;
      }
      getSnapshot().then(callback);
    });
  }

  // Stop playing audio.
  void endSnapshots() {
    recorder?.cancel();
    isForwardingSnapshots = false;
  }
}
