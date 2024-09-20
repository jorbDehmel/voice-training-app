/*
Fast Wavelet Transform in Dart
*/

import 'dart:math';

List<double> getHaarCoefficients(int n) {
  return List.generate(n, (_) => sqrt1_2);
}

double logBase(double b, double upon) {
  return log(upon) / log(b);
}

/*
Algorithm via https://link.springer.com/chapter/10.1007/978-3-319-22075-8_7

From above paper:
The input of the algorithm is an array v, with 2m+1 elements, containing the
coefficient sequence to be transformed, and the number of levels m.
*/
void fwt(List<double> v, [int m = 0, List<double> h = const []]) {
  // Handle default depth m
  if (m == 0) {
    m = logBase(2.0, v.length.toDouble()).floor() - 1;
  }

  // Ensure valid input size
  if (v.length != pow(2, m + 1)) {
    throw Exception("Invalid v dimensions! Input size must be power of 2");
  }

  // Handle default (empty) coefficients
  if (h.isEmpty) {
    h = getHaarCoefficients(m);
  }

  // Ensure valid coefficient size
  else if (h.length != m) {
    throw Exception("Invalid h dimensions!");
  }

  // Compute g from h
  List<double> g = List.filled(h.length, 0.0);
  for (int i = 0; i < h.length; i++) {
    g[i] = h[h.length - i - 1];
    if (i % 2 == 1) {
      g[i] *= -1.0;
    }
  }

  // Derived globals
  List<double> w = List.filled(v.length, 0.0);

  // Internal helper function
  void waveletDecomp(List<double> v, int n) {
    // zero(w, 0, n);
    for (int i = 0; i < n && i < w.length; i++) {
      w[i] = 0;
    }

    // Perform convolution for each index l in the first half of the array
    for (int l = 0; l < n / 2; l++) {
      int i = 2 * l;

      // Approximation coefficients (low-pass filtering)
      for (int k = 0; k < h.length; k++) {
        w[l] += v[(i + k) % n] * h[k];
      }

      // Detail coefficients (high-pass filtering)
      int m = l + (n ~/ 2);
      for (int k = 0; k < g.length; k++) {
        w[m] += v[(i + k) % n] * g[k];
      }
    }

    // Copy the transformed coefficients back into the original array v
    for (int i = 0; i < n; i++) {
      v[i] = w[i];
    }
  }

  // Actually run the decomposition
  for (int j = m; j >= 0; j--) {
    waveletDecomp(v, pow(2, j + 1).toInt());
  }
}
