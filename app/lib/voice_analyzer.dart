/*
Defines the VoiceAnalyzer class, which interfaces with external
libraries and the local DSP module to perform analysis on the
microphone stream.
*/

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:pitch_detector_dart/util/pcm_util_extensions.dart';
import 'package:record/record.dart';
import 'package:sound_library/sound_library.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'vocal_stats.dart';
import 'formants.dart';

class VoiceAnalyzer {
  AudioRecorder? recorder;
  RecordConfig recorderConfig = const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      numChannels: 1,
      autoGain: true,
      echoCancel: true,
      noiseSuppress: true);
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
            // Don't let more than 16 packets pile up
            while (buffer.length > 16) {
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
    VocalStats out = VocalStats(-1.0, -1.0);

    // Avoid using empty buffer or buffer that is already in use
    if (isPlaying || buffer.isEmpty) {
      return out;
    }

    var rawData = buffer.first;
    if (rawData.length > pitchDetector.bufferSize * 32) {
      rawData = rawData.sublist(0, pitchDetector.bufferSize * 32);
    }
    var data = rawData.convertPCM16ToFloat();

    // Extract pitch (easy part)
    final result = await pitchDetector.getPitchFromFloatBuffer(data);
    out.averagePitch = result.pitch * 2.0;

    if (out.averagePitch < 0.0 || out.averagePitch > 20000.0) {
      // Failed to fetch F0
      out.resonanceMeasure = -1.0;
      return out;
    }

    // Extract formants (hard part)
    var PCMBuffer = rawData.buffer.asByteData();
    List<double> floatList =
        List<double>.generate(rawData.length ~/ 2, (offset) {
      return PCMBuffer.getInt16(offset).toDouble();
    });
    final f1 = await getF1(
        floatList, out.averagePitch, recorderConfig.sampleRate.toDouble());
    out.resonanceMeasure = f1;

    if (f1 > 20000.0) {
      // Failed to fetch f1
      out.averagePitch = -1.0;
      out.resonanceMeasure = -1.0;
    }

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
