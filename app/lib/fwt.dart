/*
Fast Wavelet Transform in Dart
*/

import 'dart:math';

double logBase(double b, double upon) {
  return log(upon) / log(b);
}

int getSymmetricIndex(int index, int length) {
  int i = index;

  while (i < 0 || i >= length) {
    if (i < 0) {
      i = -(i + 1);
    }
    if (i >= length) {
      i = (2 * length) - (i + 1);
    }
  }

  return i;
}

/*
Return the fast wavelet transform of the input, using Haar coefficients. The
input array should have a size which is a power of two.
*/
List<double> fwt(List<double> inp) {
  // Copy input to output list
  List<double> output = List.generate(inp.length, (int i) => inp[i]);
  int n = output.length;

  int n_levels = logBase(2.0, output.length.toDouble()).floor() - 1;
  if (output.length != pow(2, n_levels + 1)) {
    throw Exception("Invalid dimensions! Input size must be power of 2");
  }

  // Get coefficients
  const List<double> scalingCoeffs = [sqrt1_2, sqrt1_2];
  const List<double> waveletCoeffs = [sqrt1_2, -sqrt1_2];

  // Iterate
  int currentLength = 2 * n;
  for (int level = 0; level <= n_levels; level++) {
    currentLength ~/= 2;

    // Temp array
    List<double> tempArray = List.filled(currentLength, 0.0);

    // Perform convolution for each index l in the first half of the array
    for (int i = 0; i < currentLength ~/ 2; i++) {
      // Approximation coefficients (low-pass filtering)
      tempArray[i] = 0.0;
      for (int j = 0; j < scalingCoeffs.length; j++) {
        tempArray[i] += output[getSymmetricIndex(2 * i + j, currentLength)] *
            scalingCoeffs[j];
      }

      // Detail coefficients (high-pass filtering)
      // int m = l + (length ~/ 2);
      tempArray[i + (currentLength ~/ 2)] = 0.0;
      for (int j = 0; j < waveletCoeffs.length; j++) {
        tempArray[i + currentLength ~/ 2] +=
            output[getSymmetricIndex(2 * i + j, currentLength)] *
                waveletCoeffs[j];
      }
    }

    // Copy the transformed coefficients back into the original array v
    for (int i = 0; i < currentLength; i++) {
      output[i] = tempArray[i];
    }
  }

  return output;
}
