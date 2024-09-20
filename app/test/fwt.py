'''
Validate output of custom FWT implementation by corroboration.
'''

import numpy as np
import pywt


def main():
    '''
    Main function
    '''

    inputs = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]

    coeffs = pywt.wavedec(inputs, 'haar', level=3)

    # Extract approximation (A) and detail (D) coefficients
    approx_coeffs = coeffs[0]  # Approximation coefficients
    detail_coeffs = coeffs[1:]  # Detail coefficients

    # Print the results
    print("Approximation Coefficients (Level 3):", approx_coeffs)
    for i, d in enumerate(detail_coeffs, start=1):
        print(f"Detail Coefficients (Level {i}):", d)

    # Concat and print as Dart fn does
    c = []
    for coeff_l in coeffs:
        c += list(coeff_l)
    print(c)


if __name__ == '__main__':
    main()
