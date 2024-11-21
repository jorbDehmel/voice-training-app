/*
Class representing a snapshot of the input microphone stream at a given moment.
This should contain everything an analysis widget needs.
*/
class VocalStats {
  double averagePitch = 0.0; // F0
  double resonanceMeasure = 0.0; // F1
  double confidence = 0.0; // UNUSED
  double volume = 0.0; // UNUSED

  // Data transfer between Dart isolates is limited to primitives and lists
  List<double> toList() {
    return <double>[averagePitch, resonanceMeasure, confidence, volume];
  }

  VocalStats(List<double> data) {
    averagePitch = data[0];
    resonanceMeasure = data[1];
    confidence = data[2];
    volume = data[3];
  }
}
