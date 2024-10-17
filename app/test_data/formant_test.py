'''
Tests generation and formant recovery scripts
'''

from hypothesis import given, settings, strategies as some
from formant_generator import TestSignalGenerator
from formant_dsp import DSPModule


SAMPLE_RATE: int = 44_100
ORDER: int = 3
RE_THRESH: float = 100.0
CASES: int = 16


def test_instance(f0: float, f1: float, f2: float) -> None:
    '''
    Generates data, then tests formant recovery on that data.
    '''

    gen: TestSignalGenerator = TestSignalGenerator(SAMPLE_RATE)
    mod: DSPModule = DSPModule(SAMPLE_RATE)

    signal = gen.generate_test_signal(1.0, f0, f1, f2)
    signal = mod.apply_window(signal)
    autocor = mod.compute_autocorrelation(signal)
    lpc = mod.compute_lpc(signal, ORDER)

    obs_f0: float = mod.estimate_f0(autocor)
    obs_f1: float = mod.estimate_f1(lpc)

    f0_re = 100.0 * abs(f0 - obs_f0) / abs(f0)
    f1_re = 100.0 * abs(f1 - obs_f1) / abs(f1)

    print(f'Exp f0: {f0} Obs f0: {obs_f0} RE: {f0_re}%')
    print(f'Exp f1: {f1} Obs f1: {obs_f1} RE: {f1_re}%')
    print('')

    assert f0_re < RE_THRESH and f1_re < RE_THRESH


if __name__ == '__main__':
    @settings(max_examples=CASES)
    @given(some.floats(min_value=100.0, max_value=10_000.0),
           some.floats(min_value=100.0, max_value=10_000.0),
           some.floats(min_value=100.0, max_value=10_000.0))
    def test_case(f0, f1, f2):
        test_instance(f0, f1, f2)

    test_case()
