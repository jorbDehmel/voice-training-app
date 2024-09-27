/*
Fast Wavelet Transform in Dart
*/

import 'dart:math';

// Returns `i` such that `(a >> i) == 1`
// This is an integer estimate.
// It runs in constant time, at most 128 iterations.
int log2(int a) {
  for (int i = 0; i < 128; ++i) {
    if ((a >> i) == 1) {
      return i;
    }
  }
  throw RangeError('log2($a) is undefined.');
}

// Produce a list of the desired length from the given list, taking averages
// where necessary.
List<double> binnify(List<double> raw, int desiredLength) {
  List<double> out = List.filled(desiredLength, 0.0);
  final int step = raw.length ~/ desiredLength;

  // Fill bins with sums
  for (int i = 0; i < raw.length; ++i) {
    if (i ~/ step < out.length) {
      out[i ~/ step] += raw[i];
    } else {
      out[out.length - 1] += raw[i];
    }
  }

  // Turn sums to averages for step-width bins
  for (int i = 0; i + 1 < out.length; ++i) {
    out[i] /= step;
  }

  // Final bin, which takes all remains.
  out[out.length - 1] /= (step + raw.length % desiredLength);

  return out;
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
Return the fast wavelet transform of the input, using Haar coefficients. If the
input array's size is not a power of two, the entries after the largest power of
two less than the size will all be averaged into the final bin such that the
input size will be a power of two.
*/
List<double> fwt(List<double> inp) {
  List<double> output;
  int nLevels = log2(inp.length) - 1;
  if (inp.length != pow(2, nLevels + 1)) {
    // Bin input list into output list
    output = binnify(inp, pow(2, nLevels + 1).floor());
  } else {
    // Copy input to output list
    output = List.generate(inp.length, (int i) => inp[i]);
  }
  int n = output.length;

  // Get coefficients (Haar)
  const List<double> scalingCoeffs = [sqrt1_2, sqrt1_2];
  const List<double> waveletCoeffs = [sqrt1_2, -sqrt1_2];

  // Iterate
  int currentLength = 2 * n;
  for (int level = 0; level <= nLevels; level++) {
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
