import sys
from typing import List
import json
from formant_dsp import get_f1


def main(args: List[str]) -> int:
    '''
    Main fn
    '''

    sample_rate: int = 44_100
    n_cases: int = 100
    filepath: str = 'test_data/formants/formants.json'

    cases = None
    with open(filepath, 'r', encoding='UTF8') as file:
        cases = json.load(file)

    for case in cases:
        inp = case['input']
        out = case['output']

        f1: float = get_f1(inp, out[0], order=3)
        print(f'RE: {100.0 * abs(out[1] - f1) / abs(out[1])}')

        return 0

    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
