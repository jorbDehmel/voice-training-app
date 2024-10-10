/*
Defines analyzer class
*/

import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:sound_library/sound_library.dart';
import 'vocal_stats.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:fftea/fftea.dart';
import 'formants.dart';

class VoiceAnalyzer {
  AudioRecorder recorder = AudioRecorder();
  List<Uint8List> buffer = [];
  StreamController<Uint8List> bufferController = StreamController();
  bool isPlaying = false;
  Duration playDelay = const Duration();
  PitchDetector pitchDetector = PitchDetector();

  VoiceAnalyzer() {
    bufferController.stream.listen((data) {
      // Don't let more than 1000 packets pile up
      if (buffer.length < 1000) {
        // Add this data packet
        buffer.add(data);
      }
    });
  }

  Future<VocalStats> getSnapshot() async {
    // Await buffer contents
    Future.doWhile(() => buffer.isEmpty);
    final data = buffer.first;
    VocalStats out = VocalStats();

    // Extract pitch (easy part)
    final result = await pitchDetector.getPitchFromIntBuffer(data);
    out.averagePitch = result.pitch;

    // Extract formants (hard part)
    final fft = FFT(data.length);
    final transformed_data = fft.realFft(data.toList().cast());

    // Return extracted statistics object
    return out;
  }

  // Play to the speakers directly from the microphone stream, with the given
  // delay in seconds. This runs until the corresponding end function is called,
  // or the object is destroyed. Only handles seconds and milliseconds.
  void beginPlayStreamWithDelay(double seconds) async {
    if (isPlaying) {
      endPlayStreamWithDelay();
    }
    isPlaying = true;
    playDelay = Duration(
        seconds: seconds.floor(), milliseconds: (seconds * 1000).floor());

    Timer.periodic(playDelay, (timer) async {
      if (!isPlaying) {
        timer.cancel();
        return;
      }

      final toPlay = buffer.removeAt(0);
      SoundPlayer.playFromBytes(toPlay);
    });
    bufferController
        .addStream(await recorder.startStream(const RecordConfig()));
  }

  // Stop playing audio.
  void endPlayStreamWithDelay() {
    recorder.cancel();
    bufferController.close();
    isPlaying = false;
  }
}
