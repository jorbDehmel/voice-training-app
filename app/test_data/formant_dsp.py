'''
Module which defines `get_f1`, which gets f1 from a given
signal.
'''

from typing import Optional
import scipy
import numpy

# "Easy" things:
# - numpy.concatenate (literally just used to prepend one item)
# - numpy.angle (angle of complex number)
# - scipy.linalg.toeplitz (Toeplitz array, google it)
# - numpy.linalg.solve (see https://pub.dev/packages/matrix_utils)
# - numpy.roots (see https://pub.dev/packages/equations)

# Hard things:
# - numpy.correlate (probably achievable? https://numpy.org/doc/stable/reference/generated/numpy.correlate.html)

def get_f1(signal: numpy.ndarray, f0: float,
           sample_rate: float = 44_100.0,
           order: int = 12) -> Optional[float]:
    '''
    Returns f1.

    :param signal: The input signal
    :param f0: The known value of f0 (the pitch)
    :param order: The number of coefficients to keep
    :returns: f1 estimate
    '''

    # These things increase accuracy, but are not strictly necessary:
    # Apply hamming window
    # signal = signal * scipy.signal.windows.hamming(len(signal))
    # Apply high-pass butter filter
    # b, a = scipy.signal.butter(order, f0 / (0.5 * sample_rate), btype='high', analog=False)
    # filtered_signal = scipy.signal.lfilter(b, a, signal)

    # Compute LPC on the filtered signal
    autocorr = numpy.correlate(signal, signal, mode='full')[len(signal)-1:]
    R = autocorr[:order + 1]
    A = numpy.linalg.solve(scipy.linalg.toeplitz(R[:-1]), -R[1:])
    lpc = numpy.concatenate([[1], A])  # LPC coefficients

    # Estimate F1 (lowest frequency above F0)
    rts = numpy.roots(lpc)  # Find roots of LPC polynomial
    rts = [r for r in rts if abs(r) < 1]  # Keep roots inside unit circle

    # Convert roots to frequencies and filter out those below F0
    freqs = [(numpy.angle(r) * (sample_rate / (2 * numpy.pi))) for r in rts]
    freqs_above_f0 = [f for f in freqs if f > f0]

    return min(freqs_above_f0) if freqs_above_f0 else None  # Return F1
