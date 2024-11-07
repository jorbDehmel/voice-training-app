import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voice_training_app/voice_analyzer.dart';

class AnalysisPageState extends State<AnalysisPage> {
  VoiceAnalyzer? analyzer;

  @override
  Widget build(BuildContext context) {
    analyzer = VoiceAnalyzer();
    analyzer?.getSnapshot().then((snapshot) {
      print(snapshot);
    });

    if (analyzer == null || analyzer!.recorder == null) {
      return Scaffold(
          body: Column(children: [
        BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const Text('An error occurred, and the microphone '
            'could not be accessed; You may be on an '
            'unsupported platform.'),
      ]));
    }

    return Scaffold(body: BackButton(
      onPressed: () {
        Navigator.pop(context);
      },
    ));
  }

  @override
  void dispose() {
    analyzer?.dispose();
    analyzer = null;
    super.dispose();
  }
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key}) : title = "Analysis";
  final String title;

  @override
  State<StatefulWidget> createState() {
    return AnalysisPageState();
  }
}
