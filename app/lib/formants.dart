/*
Signal processing things for Flutter voice training app. This
was largely adapted from Python.
*/

import 'dart:math';
import 'package:equations/equations.dart';

// The number of coefficients to keep. The more the better, but
// 3 is good enough for our results to be proportional to the
// correct results.
const int order = 3;

/*
Gets F1 (very inaccurately). Uses order 3 polynomials. This
should be within about 50% relative error
https://chatgpt.com/share/6707f4fd-18a4-8009-8846-27f109be7bd7
*/
Future<double> getF1(signal, double f0, double sampleRate) async {
  // Compute LPC on the filtered signal
  final autocorr = autocorrelate(signal);
  final R = autocorr.getRange(0, order + 1).toList();
  final coeffMatrix = toeplitz(R.getRange(0, R.length - 1).toList());
  final knownVals = List.generate(R.length - 1, (i) {
    return -R[i + 1];
  });

  final A = solveLinSys(coeffMatrix, knownVals);

  var lpc = List<double>.from(const [1.0], growable: true);
  lpc.addAll(A);

  // Estimate F1 (lowest frequency above F0)
  var rts = cubicRoots(
      lpc[3], lpc[2], lpc[1], lpc[0]); // Find roots of LPC polynomial

  rts = rts.where((item) {
    return item.abs() < 1.0;
  }).toList(); // Keep roots inside unit circle

  // Convert roots to frequencies and filter out those below F0
  final freqs = List<double>.generate(rts.length, ((i) {
    var r = rts[i];
    return angle(r) * (sampleRate / (2 * pi));
  }));
  final freqsAboveF0 = freqs.where((f) {
    return f > f0;
  }).toList();

  if (freqsAboveF0.isEmpty) {
    return -1.0;
  } else {
    var min = freqsAboveF0.first;
    for (int i = 1; i < freqsAboveF0.length; ++i) {
      if (freqsAboveF0[i] < min) {
        min = freqsAboveF0[i];
      }
    }
    return min;
  }
}

/*
Return the angle in Radians off the positive real axis of the
given complex point. Bounded by $\pm \pi$.
*/
double angle(Complex p) {
  return atan2(p.imaginary, p.real);
}

// returns the Toeplitz matrix where the first column is that
// given and the first row is the conjugate of the first col.
RealMatrix toeplitz(List<double> firstCol) {
  // First row (0th item can be ignored)
  final firstRow = firstCol;

  // Construct fake matrix
  List<List<double>> data = List<List<double>>.empty(growable: true);
  data.add(firstRow);
  for (int row = 1; row < firstCol.length; ++row) {
    data.add(List.generate(firstRow.length, (col) {
      if (col == 0) {
        return firstCol[row];
      } else {
        return data.last[col - 1];
      }
    }));
  }

  // Build into real out
  return RealMatrix.fromData(
      rows: firstCol.length, columns: firstCol.length, data: data);
}

// Solve a linear system of equations
// (see https://pub.dev/packages/matrix_utils)
List<double> solveLinSys(RealMatrix coeffs, List<double> rhs) {
  return CholeskySolver(matrix: coeffs, knownValues: rhs).solve();
}

// Return a list of complex roots of the cubic polynomial
// a is lowest degree, d is highest
List<Complex> cubicRoots(double a, double b, double c, double d) {
  // Note: Highest degree goes first
  return Algebraic.fromReal([d, c, b, a]).solutions();
}

// Compute full correlation list of two complex lists
// https://numpy.org/doc/stable/reference/generated/numpy.correlate.html)
List<double> autocorrelate(List<double> a) {
  // $c_k = \sum_n a_{n + k} \cdot \bar{v_n}$
  // Where $\bar{v}$ is the complex conjugate of $v$
  // By default, mode is ‘full’. This returns the convolution at
  // each point of overlap, with an output shape of (N+M-1,). At
  // the end-points of the convolution, the signals do not
  // overlap completely, and boundary effects may be seen.
  int len = a.length;
  List<double> result = List.filled(2 * len - 1, 0.0);

  for (int k = -(len - 1); k < len; ++k) {
    double sum = 0.0;
    for (int n = max(0, -k); n < min(len, len - k); ++n) {
      sum += a[n] * a[n + k];
    }
    result[k + len - 1] = sum;
  }

  return result.getRange(0, a.length).toList().reversed.toList();
}
