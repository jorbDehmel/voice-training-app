/*
Defines analyzer class
*/

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:sound_library/sound_library.dart';
import 'vocal_stats.dart';
import 'formants.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';

class VoiceAnalyzer {
  AudioRecorder? recorder;
  RecordConfig recorderConfig = const RecordConfig();
  Queue<Uint8List> buffer = Queue<Uint8List>();
  StreamController<Uint8List> bufferController = StreamController();
  bool isPlaying = false, isForwardingSnapshots = false;
  Duration playDelay = const Duration();
  PitchDetector pitchDetector = PitchDetector();

  VoiceAnalyzer() {
    try {
      recorder = AudioRecorder();
    } on UnimplementedError {
      recorder = null;
      print('Failed to instantiate recorder!');
    }

    // Check validity of recorder
    recorder?.hasPermission().then((hasPermission) {
      if (hasPermission) {
        recorder?.isRecording().then((isRecording) {
          if (isRecording) {
            // Register buffer handler lambda
            bufferController.stream.listen((data) {
              // Don't let more than 100 packets pile up
              while (buffer.length > 128) {
                buffer.removeFirst();
              }
              // Add this data packet to the end
              buffer.add(data);
            });
          } else {
            print('Failed to start recording!');
          }
        });
      } else {
        print('Failed to get microphone permission!');
      }
    });
  }

  void dispose() {
    endPlayStreamWithDelay();
  }

  Future<VocalStats> getSnapshot() async {
    VocalStats out = VocalStats();
    out.averagePitch = out.confidence = 0.0;
    out.resonanceMeasure = out.volume = 0.0;

    // Avoid using empty buffer or buffer that is already in use
    if (isPlaying || buffer.isEmpty) {
      return out;
    }
    final data = buffer.first;

    // Extract pitch (easy part)
    final result = await pitchDetector.getPitchFromIntBuffer(data);
    out.averagePitch = result.pitch;

    // Extract formants (hard part)
    final f1 = await getF1(
        data, out.averagePitch, recorderConfig.sampleRate.toDouble());
    out.resonanceMeasure = f1;

    // Return extracted statistics object
    return out;
  }

  // Play to the speakers directly from the microphone stream, with the given
  // delay in seconds. This runs until the corresponding end function is called,
  // or the object is destroyed. Only handles seconds and milliseconds.
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
    bufferController.addStream(await recorder!.startStream(recorderConfig));
  }

  // Stop playing audio.
  void endPlayStreamWithDelay() {
    recorder?.cancel();
    bufferController.close();
    isPlaying = false;
  }

  // Register a callback to receive snapshots upon microphone
  // update.
  void beginSnapshots(callback) async {
    if (isPlaying) {
      endPlayStreamWithDelay();
    } else if (isForwardingSnapshots) {
      endSnapshots();
    } else if (recorder == null) {
      return;
    }
    isForwardingSnapshots = true;

    Timer.periodic(playDelay, (timer) async {
      if (!isForwardingSnapshots) {
        timer.cancel();
        return;
      } else if (buffer.isEmpty) {
        return;
      }
      callback(getSnapshot());
    });
    bufferController.addStream(await recorder!.startStream(recorderConfig));
  }

  // Stop playing audio.
  void endSnapshots() {
    recorder?.cancel();
    bufferController.close();
    isForwardingSnapshots = false;
  }
}
