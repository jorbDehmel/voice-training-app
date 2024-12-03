/*
Class representing a snapshot of the input microphone stream at a given moment.
This should contain everything an analysis widget needs.
*/
class VocalStats {
  double averagePitch; // F0
  double resonanceMeasure; // F1
  VocalStats(double p, double res)
      : averagePitch = p,
        resonanceMeasure = res;
}
