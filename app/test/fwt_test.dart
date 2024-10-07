import 'package:flutter_test/flutter_test.dart';

/*
Tests the fast wavelet transform as implemented for this app.
*/

import 'dart:convert';
import 'dart:io';
import 'package:voice_training_app/fwt.dart';

int main() {
  test('Binnify function works as expected', () {
    final List<double> inp = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    final List<double> exp = [1.5, 3.5, 5.5, 8.5];
    final List<double> obs = binnify(inp, exp.length);

    try {
      assert(obs.length == exp.length);
      for (int i = 0; i < obs.length; ++i) {
        assert(obs[i] == exp[i]);
      }
    } catch (e) {
      print('$e');
      print('Expected: $exp');
      print('Observed: $obs');
      rethrow;
    }
  });

  test('Binnify function works as expected', () {
    final List<double> inp = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    final List<double> exp = [2, 5, 8, 11];
    final List<double> obs = binnify(inp, exp.length);

    try {
      assert(obs.length == exp.length);
      for (int i = 0; i < obs.length; ++i) {
        assert(obs[i] == exp[i]);
      }
    } catch (e) {
      print('$e');
      print('Expected: $exp');
      print('Observed: $obs');
      rethrow;
    }
  });

  test('FWT passes JSON cases', () {
    final file = File.fromUri(Uri.file('test_data/test_data.json'));
    file.readAsString().then((String contents) {
      final List<dynamic> dataList = jsonDecode(contents);
      Stopwatch timer = Stopwatch();

      timer.start();
      for (var testCase in dataList) {
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
      }
      timer.stop();

      print('Executed ${dataList.length} cases in '
          '${timer.elapsedMicroseconds} us, averaging '
          '${timer.elapsedMicroseconds / dataList.length} us/case.');

      return;
    });
  });

  test('Bin sizing must be minimal', () {
    for (int i = 1; i < 1000000; ++i) {
      final int shift = log2(i);
      assert((1 << shift) <= i);
      assert((1 << (shift + 1)) > i);
    }

    bool didError = false;
    try {
      final int shift = log2(0);
    } catch (e) {
      didError = true;
    }
    assert(didError);
    didError = false;
    try {
      final int shift = log2(-10);
    } catch (e) {
      didError = true;
    }
    assert(didError);
  });

  return 0;
}
