/*
Class representing a snapshot of the input microphone stream at a given moment.
This should contain everything an analysis widget needs.
*/
class VocalStats {
  double averagePitch = 0.0; // F0
  double resonanceMeasure = 0.0; // F1
  double confidence = 0.0; // UNUSED
  double volume = 0.0; // UNUSED
}
