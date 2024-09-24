/*
Tests the fast wavelet transform as implemented for this app.
*/

import 'dart:math';

import 'package:app/fwt.dart';

int main(List<String> args) {
  List<double> v = args.map((item) => double.parse(item)).toList();
  var out = fwt(v);

  print('$out');

  return 0;
}
