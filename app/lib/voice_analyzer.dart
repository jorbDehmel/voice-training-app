/*
Defines analyzer class
*/

import 'dart:typed_data';
import 'dart:math';
import 'package:record/record.dart';
import 'vocal_stats.dart';
import './fwt.dart';

/*
Note: This should probably be a singleton, as it manages a recorder.
*/
class VoiceAnalyzer {
  final AudioRecorder recorder = AudioRecorder();
  late Future<Stream<Uint8List>> strm;

  // Analysis is done on the last 2^resolutionBits microphone
  // readings. It's formatted this way to ensure that the array input to the
  // wavelet transform is a power of two.
  final int resolutionBits = 8;
  Uint8List? buffer;

  VoiceAnalyzer() {
    strm = recorder.startStream(const RecordConfig());

    // Upon stream resolution
    strm.then((what) {
      // Attach callback for when mic data is yielded
      what.listen((data) {
        // Assert valid value for resolutionBits
        assert(data.length == pow(2, resolutionBits));

        // Use the current yielded data as buffer
        buffer = data;
      });
    });
  }

  Future<VocalStats> getSnapshot() async {
    // Await buffer contents
    Future.doWhile(() => buffer == null);

    // Perform wavelet transform on current buffer contents
    var transformed = fwt(buffer!.toList().cast());

    // Extract relevant information from wavelet transform (???)
    throw UnimplementedError();

    // Return extracted statistics object
    return VocalStats();
  }

  // Play to the speakers directly from the microphone stream, with the given
  // delay in seconds. This runs until the corresponding end function is called,
  // or the object is destroyed. Only handles seconds and milliseconds.
  void beginPlayStreamWithDelay(double s) {
    Future.delayed(
        Duration(seconds: s.floor(), milliseconds: (s * 1000.0).floor()),
        () => ());
  }

  // Stop playing audio.
  void endPlayStreamWithDelay() {}
}
