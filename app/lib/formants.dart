/*
Gets F0 and F1

Data -> Preprocessing -> FFT -> LPC -> Truncate to only cubic coefficients ->
find roots of cubic -> complex log of the roots (imaginary part is phase) ->
inverse fourier to get cepstral

https://chatgpt.com/share/6707f4fd-18a4-8009-8846-27f109be7bd7
*/
List<double> getFormants(UInt8List data) {
    // Preprocessing

    // FFT
    final fftData = fft(data);

    // LPC
    final lpcData = lpc(fftData);

    // Truncate to cubic
    final a = lpcData[0];
    final b = lpcData[1];
    final c = lpcData[2];
    final d = lpcData[3];

    // Find roots of cubic
    final roots = realRootsOfCubic(a, b, c, d);

    // Complex log
    final logVals = complexLog(roots);

    // Imaginary part only

    // IFFT
    final ifftData = ifft(imaginaryData);

    // Return 2 formants
    return ifftData;
}

// Returns a list of the real roots of the given cubic polynomial
// = a + bx + cx^2 + dx^3
List<double> realRootsOfCubic(double a, double b, double c, double d) {
  List<double> out = List<double>();

  // Find roots

  return out;
}

// Returns the complex log of each of its arguments
List<complex> complexLog(List<double> of) {
}

List<double> lpc(List<double> signal, int order) {
  return [];
}
