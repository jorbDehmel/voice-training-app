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

Uses Haar.
*/
List<double> fwt(List<double> inp) {
  // Copy input to output list
  List<double> output = List.generate(inp.length, (int i) => inp[i]);

  int depth = logBase(2.0, output.length.toDouble()).floor() - 1;
  if (output.length != pow(2, depth + 1)) {
    throw Exception("Invalid v dimensions! Input size must be power of 2");
  }

  // Compute coefficients
  List<double> scaling_coeffs = getHaarCoefficients(depth);
  List<double> wavelet_coeffs = List.filled(scaling_coeffs.length, 0.0);

  for (int i = 0; i < scaling_coeffs.length; i++) {
    wavelet_coeffs[i] = scaling_coeffs[scaling_coeffs.length - i - 1];
    if (i % 2 == 1) {
      wavelet_coeffs[i] *= -1.0;
    }
  }

  // Temp array
  List<double> temp_array = List.filled(output.length, 0.0);

  // Iterate
  for (int j = depth; j >= 0; j--) {
    int length = pow(2, j + 1).toInt();

    // Zero out the relevant region of the temp array
    for (int i = 0; i < length; i++) {
      temp_array[i] = 0;
    }

    // Perform convolution for each index l in the first half of the array
    for (int l = 0; l < length / 2; l++) {
      int i = 2 * l;

      // Approximation coefficients (low-pass filtering)
      for (int coeff_ind = 0; coeff_ind < scaling_coeffs.length; coeff_ind++) {
        temp_array[l] +=
            output[(i + coeff_ind) % length] * scaling_coeffs[coeff_ind];
      }

      // Detail coefficients (high-pass filtering)
      int m = l + (length ~/ 2);
      for (int k = 0; k < wavelet_coeffs.length; k++) {
        temp_array[m] += output[(i + k) % length] * wavelet_coeffs[k];
      }
    }

    // Copy the transformed coefficients back into the original array v
    for (int i = 0; i < length; i++) {
      output[i] = temp_array[i];
    }
  }

  return output;
}
