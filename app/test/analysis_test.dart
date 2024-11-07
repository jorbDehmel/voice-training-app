/*
Test analysis
*/

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'dart:io';
import 'package:voice_training_app/formants.dart';

abs(x) => x < 0.0 ? -x : x;

int main() {
  test('Test unjittered data', () async {
    const double sampleRate = 44100;
    const filepath = 'test_data/formants/formants.json';

    File(filepath).readAsString().then((input) async {
      var cases = jsonDecode(input);
      var sum = 0.0;
      for (var c in cases) {
        final List<double> inp = List<double>.from(c['input']);
        final List<double> out = List<double>.from(c['output']);

        final double f0 = out[0];
        final double exp_f1 = out[1];
        final double obs_f1 = await getF1(inp, f0, sampleRate);

        final double re = 100.0 * abs(exp_f1 - obs_f1) / abs(exp_f1);

        assert(obs_f1 != -1.0);
        assert(re < 200.0);

        print('RE: $re');
        sum += re;
      }
      print('Mean RE: ${sum / cases.length}');
    });
  });

  test('Test jittered data', () async {
    const double sampleRate = 44100;
    const filepath = 'test_data/formants/formants_jitter.json';

    File(filepath).readAsString().then((input) async {
      var cases = jsonDecode(input);
      var sum = 0.0;
      for (var c in cases) {
        final List<double> inp = List<double>.from(c['input']);
        final List<double> out = List<double>.from(c['output']);

        final double f0 = out[0];
        final double exp_f1 = out[1];
        final double obs_f1 = await getF1(inp, f0, sampleRate);

        final double re = 100.0 * abs(exp_f1 - obs_f1) / abs(exp_f1);

        assert(obs_f1 != -1.0);
        assert(re < 200.0);

        print('RE: $re');
        sum += re;
      }
      print('Mean RE: ${sum / cases.length}');
    });
  });

  return 0;
}
