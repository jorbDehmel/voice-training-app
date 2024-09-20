/*
Tests the fast wavelet transform as implemented for this app.
*/

import 'dart:math';

import 'package:app/fwt.dart';

int main() {
  List<double> v = [1, 2, 3, 4, 5, 6, 7, 8];
  print('Before transform:  $v');

  fwt(v);

  print('After transform:   $v');

  return 0;
}
