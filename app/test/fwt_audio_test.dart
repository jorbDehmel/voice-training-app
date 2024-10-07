/*
This is my second time writing this file: I don't know why I deleted the first
one T_T.
- Jordan

This is NOT a unit testing file! It generates data for analysis via Python
scripts on existing WAV files.
*/

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:voice_training_app/fwt.dart';
import 'package:typed_data/typed_data.dart';

bool doesLocalMatch(Uint8List contents, pos) {
  if (contents[pos] != ascii.encode('d')) {
    return false;
  } else if (contents[pos + 1] != ascii.encode('a')) {
    return false;
  } else if (contents[pos + 1] != ascii.encode('t')) {
    return false;
  } else if (contents[pos + 1] != ascii.encode('a')) {
    return false;
  }
  return true;
}

main() {
  for (var filepath in ['test_data/amazing-grace-1.wav']) {
    File.fromRawPath(ascii.encode(filepath)).readAsBytes().then(
        (Uint8List contents) {
      // Get offset
      var i = 0;
      for (i = 0; i + 4 < contents.length; ++i) {
        if (doesLocalMatch(contents, i)) {
          break;
        }
      }
      if (i + 4 >= contents.length) {
        throw Exception('Data wasn\'t found in provided WAV.');
      }

      // Read remainder of file
      var data = contents.sublist(i);
      print(fwt(data.toList().cast()));
    }, onError: () {
      throw Exception('Failed to open file');
    });
  }
}
