from random import uniform
from formant_generator import TestSignalGenerator
from formant_dsp import get_f1

SAMPLE_RATE = 44_100
ORDER = 3

def test_instance(f0: float, f1: float, f2: float) -> None:
    print(f'Test case: F0={round(f0, 3)}, F1={round(f1, 3)}, F2={round(f2, 3)}')

    gen = TestSignalGenerator(SAMPLE_RATE)

    # Generate and window the signal
    signal = gen.generate_test_signal(1.0, f0, f1, f2)

    obs_f1 = get_f1(signal, f0, SAMPLE_RATE, ORDER)

    # Compute relative error for F1
    f1_re = 100.0 * abs(f1 - obs_f1) / abs(f1) if obs_f1 else float('inf')

    print(f'Expected F1: {round(f1, 3)}, Observed F1: {round(obs_f1, 3)}, RE: {round(f1_re, 3)}%')


if __name__ == '__main__':
    for test_case in range(100):
        test_instance(
            uniform(100.0, 500.0),
            uniform(500.0, 1_000.0),
            uniform(1_000, 10_000.0))
