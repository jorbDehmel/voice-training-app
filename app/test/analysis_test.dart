/*
Test analysis
*/

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'dart:io';
import 'package:voice_training_app/formants.dart';

abs(x) => x < 0.0 ? -x : x;

main() async {
  test('Test unjittered data', () async {
    const double sampleRate = 44100;
    const filepath = 'test_data/formants/formants.json';

    final input = await File(filepath).readAsString();

    final cases = jsonDecode(input);
    assert(!cases.isEmpty);
    var sum = 0.0;

    for (var c in cases) {
      final List<double> inp = List<double>.from(c['input']);
      final List<double> out = List<double>.from(c['output']);

      final double f0 = out[0];
      final double expF1 = out[1];
      final obsF1 = await getF1(inp, f0, sampleRate);

      final double re = 100.0 * abs(expF1 - obsF1) / abs(expF1);

      if (obsF1 == -1.0) {
        continue;
      }

      assert(re < 50.0);

      print('Exp: $expF1 Obs: $obsF1');
      print('RE: $re');
      sum += re;
    }
    print('Mean RE: ${sum / cases.length}');
  });

  test('Test jittered data', () async {
    const double sampleRate = 44100;
    const filepath = 'test_data/formants/formants_jitter.json';

    final input = await File(filepath).readAsString();
    var cases = jsonDecode(input);
    var sum = 0.0;
    for (var c in cases) {
      final List<double> inp = List<double>.from(c['input']);
      final List<double> out = List<double>.from(c['output']);

      final double f0 = out[0];
      final double expF1 = out[1];
      final double obsF1 = await getF1(inp, f0, sampleRate);

      final double re = 100.0 * abs(expF1 - obsF1) / abs(expF1);

      if (obsF1 == -1.0) {
        continue;
      }

      assert(re < 100.0);

      print('RE: $re');
      sum += re;
    }
    print('Mean RE: ${sum / cases.length}');
  });

  return 0;
}
