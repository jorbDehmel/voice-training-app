'''
'''

import sys
import numpy as np
import scipy.signal as signal
import scipy.io.wavfile as wav
import scipy.fft as fft
from matplotlib import pyplot as plt


class TestSignalGenerator:
    '''
    '''

    def __init__(self, sample_rate):
        self.sample_rate = sample_rate

    def generate_test_signal(self, duration, f0, f1, f2):
        total_samples = int(duration * self.sample_rate)
        # Generate source signal (harmonic series)
        source_signal = self._generate_source_signal(f0, total_samples)

        # Design formant filters
        formant1_b, formant1_a = self._design_formant_filter(f1)
        formant2_b, formant2_a = self._design_formant_filter(f2)

        # Apply formant filters
        signal_after_f1 = signal.lfilter(formant1_b, formant1_a, source_signal)
        signal_after_f2 = signal.lfilter(formant2_b, formant2_a, signal_after_f1)

        return signal_after_f2

    def _generate_source_signal(self, f0, total_samples):
        t = np.arange(total_samples) / self.sample_rate
        num_harmonics = int(self.sample_rate / (2 * f0))  # Up to Nyquist frequency
        source_signal = np.zeros_like(t)
        print(num_harmonics)
        for k in range(1, num_harmonics + 1):
            if k % 1_000 == 0:
                print(k)
            source_signal += (1.0 / k) * np.sin(2 * np.pi * f0 * k * t)
        # Normalize the signal
        max_amp = np.max(np.abs(source_signal))
        if max_amp > 0:
            source_signal = source_signal / max_amp
        return source_signal

    def _design_formant_filter(self, center_freq):
        bandwidth = 100.0  # Adjust as needed for different vowel qualities
        # Calculate filter parameters
        r = np.exp(-np.pi * bandwidth / self.sample_rate)
        theta = 2 * np.pi * center_freq / self.sample_rate
        poles = [r * np.exp(1j * theta), r * np.exp(-1j * theta)]
        zeros = [0, 0]
        b, a = signal.zpk2tf(zeros, poles, 1)
        return b, a


if __name__ == '__main__':
    assert len(sys.argv) == 5

    f0: float = float(sys.argv[1])
    f1: float = float(sys.argv[2])
    f2: float = float(sys.argv[3])

    target: str = sys.argv[4]

    gen = TestSignalGenerator(44100)
    sig = gen.generate_test_signal(1.0, f0, f1, f2)

    fft_data = fft.fftshift(fft.fft(sig))
    plt.vlines([f0, f1, f2], ymin=min(fft_data), ymax=max(fft_data))
    plt.plot(fft_data)
    plt.show()

    wav.write(target, 44100, sig.astype(np.uint8))

    sys.exit(0)
