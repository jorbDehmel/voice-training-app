/*
Defines analyzer class
*/

import 'package:record/record.dart';
import 'package:fftea/fftea.dart';
import './vocalstats.dart';
import './fwt.dart';

/*
Note: This should probably be a singleton, as it manages a recorder.
*/
class VoiceAnalyzer {
  final AudioRecorder recorder = AudioRecorder();

  VoiceAnalyzer() {}
}
