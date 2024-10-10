/*
Data -> Preprocessing -> FFT -> LPC -> Truncate to only cubic coefficients ->
find roots of cubic -> complex log of the roots (imaginary part is phase) ->
inverse fourier to get cepstral

https://chatgpt.com/share/6707f4fd-18a4-8009-8846-27f109be7bd7
*/

List<double> lpc(List<double> signal, int order) {
  return [];
}

// Placeholder: Return example formant frequencies
List<double> getFormantsFromLPC(List<double> lpcCoeffs, double sampleRate) {
  return [500.0, 1500.0];
}
