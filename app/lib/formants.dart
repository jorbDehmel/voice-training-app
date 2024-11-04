import 'dart:math';
import 'package:equations/equations.dart';

const int order = 3;

/*
Gets F1 (very inaccurately). Uses order 3 polynomials. This
should be within about 50% relative error
https://chatgpt.com/share/6707f4fd-18a4-8009-8846-27f109be7bd7
*/
Future<double> getF1(signal, double f0, double sampleRate) async {
  // Compute LPC on the filtered signal
  final autocorr = correlate(signal, signal)
      .getRange(signal.length - 1, (2 * signal.length - 1).toInt())
      .toList();

  final R = autocorr.getRange(0, order).toList();

  final coeffMatrix = toeplitz(R.getRange(0, R.length - 1).toList());
  final knownVals = List.generate(R.length - 1, (i) {
    return -R[i + 1];
  });

  final A = solveLinSys(coeffMatrix, knownVals);

  var lpc = const [1.0];
  lpc.addAll(A);

  // Estimate F1 (lowest frequency above F0)
  var rts = cubicRoots(
      lpc[0], lpc[1], lpc[2], lpc[3]); // Find roots of LPC polynomial
  rts = rts.where((item) {
    return item.abs() < 1.0;
  }).toList(); // Keep roots inside unit circle

  // Convert roots to frequencies and filter out those below F0
  final freqs = List<double>.generate(rts.length, ((i) {
    var r = rts[i];
    return (angle(r) * (sampleRate / (2 * pi)));
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
  if (p.real < 0.0) {
    // Negative angle
    return -tan(p.imaginary / p.real);
  } else {
    // Positive angle
    return tan(p.imaginary / p.real);
  }
}

// returns the Toeplitz matrix where the first column is that
// given and the first row is the conjugate of the first col.
RealMatrix toeplitz(List<double> firstCol) {
  // First row (0th item can be ignored)
  final firstRow = List.generate(firstCol.length, (i) {
    return -firstCol[i];
  }, growable: false);

  // Construct fake matrix
  List<List<double>> data = List<List<double>>.empty();
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

// - numpy.linalg.solve (see https://pub.dev/packages/matrix_utils)
List<double> solveLinSys(RealMatrix coeffs, List<double> rhs) {
  return GaussSeidelSolver(matrix: coeffs, knownValues: rhs).solve();
}

// Return a list of complex roots of the cubic polynomial
// $a + bx + cx^2 + dx^3$
List<Complex> cubicRoots(double a, double b, double c, double d) {
  // Note: Highest degree goes first
  return Algebraic.fromReal([d, c, b, a]).solutions();
}

// Compute full correlation list of two complex lists
// https://numpy.org/doc/stable/reference/generated/numpy.correlate.html)
List<double> correlate(List<double> a, List<double> v) {
  // $c_k = \sum_n a_{n + k} \cdot \bar{v_n}$
  // Where $\bar{v}$ is the complex conjugate of $v$
  // By default, mode is ‘full’. This returns the convolution at
  // each point of overlap, with an output shape of (N+M-1,). At
  // the end-points of the convolution, the signals do not
  // overlap completely, and boundary effects may be seen.
  return List<double>.generate(a.length + v.length - 1, (i) {
    double sum = 0.0;
    for (int j = 0; j < a.length; ++j) {
      final k = i - j;
      if (k >= 0 && k < v.length) {
        sum += a[j] * v[k];
      }
    }
    return sum;
  });
}
