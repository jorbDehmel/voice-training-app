'''
Validate output of custom FWT implementation by corroboration.
'''

from typing import List
from math import log2
import subprocess
from hypothesis import given, settings, strategies as some
import pywt


def test_fwt_on(inputs: List[float]):

    coeffs = pywt.wavedec(inputs, 'haar',
                        level=int(log2(len(inputs))))

    # Concat and print as Dart fn does
    python_values = []
    for coeff_l in coeffs:
        python_values += [round(float(item), 5)
                          for item in coeff_l]

    dart_values = subprocess.check_output(
            ['dart', 'test/test_fwt.dart'] +
            [str(i) for i in inputs]
        ).decode('UTF8')[1:-2].split(', ')
    dart_values = [round(float(i), 5) for i in dart_values]

    print(f'Python gives: {python_values}')
    print(f'Dart gives:   {dart_values}')

    try:
        assert len(python_values) == len(dart_values)

        for i, ours in enumerate(python_values):
            assert ours == dart_values[i]

        print('Pass!')

    except AssertionError as e:
        print('Fail...')

        raise e


def main():
    '''
    Main function
    '''

    for size in range(2, 8):

        vec_size = 2 ** size
        print(f'Testing size {vec_size}...')

        @given(
            some.lists(
                some.floats(
                    min_value=-255.0,
                    max_value=255.0),
                min_size=vec_size,
                max_size=vec_size))
        @settings(max_examples=10, deadline=None)
        def do_inner_thing(vec: List[float]):
            test_fwt_on(vec)

        do_inner_thing()


if __name__ == '__main__':
    main()
