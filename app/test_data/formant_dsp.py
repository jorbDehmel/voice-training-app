import sys
from typing import List
import numpy as np
from numpy.fft import fft, ifft
from scipy.signal.windows import hamming
import scipy.io.wavfile as wav

class DSPModule:
    def __init__(self, sample_rate):
        self.sample_rate = sample_rate

    def apply_window(self, signal):
        window = hamming(len(signal), sym=False)
        return signal * window

    def compute_autocorrelation(self, signal):
        N = len(signal)
        # Zero-padding for efficient FFT computation
        fft_size = 2 ** int(np.ceil(np.log2(2 * N - 1)))
        signal_fft = fft(signal, n=fft_size)
        power_spectrum = np.abs(signal_fft) ** 2
        autocorr = ifft(power_spectrum).real
        autocorr = autocorr[:N] / N
        return autocorr

    def estimate_f0(self, autocorrelation):
        # Ignore zero lag
        autocorr = autocorrelation[1:]
        peak_index = np.argmax(autocorr) + 1  # +1 to correct index
        if peak_index <= 0:
            return 0.0
        return self.sample_rate / peak_index

    def compute_lpc(self, signal, order):
        # Compute autocorrelation
        autocorr = np.correlate(signal, signal, mode='full')
        autocorr = autocorr[len(signal) - 1:]
        r = autocorr[:order + 1]
        # Perform Levinson-Durbin recursion
        lpc_coeffs, _ = self._levinson_durbin(r, order)
        return lpc_coeffs

    def _levinson_durbin(self, r, order):
        """Levinson-Durbin recursion for LPC coefficients."""
        a = np.zeros(order + 1)
        e = np.zeros(order + 1)
        a[0] = 1.0
        e[0] = r[0]
        for i in range(1, order + 1):
            acc = np.dot(a[:i], r[i:0:-1])
            k = - (r[i] + acc) / e[i - 1]
            a[1:i + 1] += k * a[i - 1::-1]
            e[i] = e[i - 1] * (1 - k * k)
        return a, e[-1]

    def estimate_f1(self, lpc_coeffs):
        # Find roots of LPC polynomial
        roots = np.roots(lpc_coeffs)
        # Keep roots inside the unit circle
        roots = roots[np.abs(roots) < 1]
        # Convert roots to frequencies
        angles = np.angle(roots)
        formant_freqs = angles * (self.sample_rate / (2 * np.pi))
        # Keep positive frequencies
        formant_freqs = formant_freqs[formant_freqs > 0]
        formant_freqs = np.sort(formant_freqs)
        # Return the first formant frequency
        return formant_freqs[0] if len(formant_freqs) > 0 else 0.0


if __name__ == '__main__':
    assert len(sys.argv) == 2, 'Please provide a filename.'

    ORDER: int = 8
    mod: DSPModule = DSPModule(44100)

    # Get sample
    rate, signal = wav.read(sys.argv[1])
    print(f'Rate: {rate}')

    # Preprocessing
    signal = mod.apply_window(signal)
    autocor: float = mod.compute_autocorrelation(signal)
    f0: float = mod.estimate_f0(autocor)

    lpc: List[float] = mod.compute_lpc(signal, ORDER)
    f1: float = mod.estimate_f1(lpc)

    print(f'f0: {f0}, f1: {f1}')
