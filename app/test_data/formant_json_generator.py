import sys
import json
from random import uniform
from typing import List, Dict
from formant_generator import TestSignalGenerator as Generator


def main(argv: List[str]) -> int:
    '''
    Main fn
    :returns: Exit code (0 on success)
    '''

    sample_rate: int = 44_100
    n_cases: int = 32
    jitter_perc: float = 0.01
    filepath: str = 'test_data/formants/formants_jitter.json'

    to_jsonify: List[Dict[str, str]] = []
    generator: Generator = Generator(sample_rate)

    for _ in range(n_cases):

        f0: float = uniform(100.0, 500.0)
        f1: float = uniform(500.0, 2_000.0)
        f2: float = uniform(1_500.0, 10_000.0)

        s = generator.generate_test_signal(0.1, f0, f1, f2)
        input_vec: List[float] = list(s)

        # Jitter every reading by up to 2%
        for i, item in enumerate(input_vec):
            input_vec[i] += uniform(-item * jitter_perc, item * jitter_perc)

        output_vec: List[float] = [f0, f1, f2]
        to_jsonify.append({
            'input': input_vec,
            'output': output_vec})

    with open(filepath, 'w', encoding='UTF8') as file:
        json.dump(to_jsonify, file)

    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
