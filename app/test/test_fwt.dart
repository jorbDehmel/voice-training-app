/*
Tests the fast wavelet transform as implemented for this app.
*/

import 'dart:convert';
import 'dart:io';
import 'package:app/fwt.dart';

int main(List<String> args) {
  File f = File.fromUri(Uri.file('test_data.json'));

  f.readAsString().then((String contents) {
    final List<dynamic> dataList = jsonDecode(contents);
    dataList.forEach((testCase) {
      // Get case data from dynamic json object
      final List<double> input = List<double>.from(testCase['input'] as List);
      final List<double> expected =
          List<double>.from(testCase['output'] as List);
      final List<double> observed = fwt(input);

      // Assert our calculations are correct
      assert(expected.length == observed.length);
      for (int i = 0; i < expected.length; i++) {
        assert(expected[i] == observed[i]);
      }
    });
  });

  return 0;
}
