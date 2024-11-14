/*
The page which displays a f0/f1 axis to the user based on the
microphone input. This is just a frontend, the real computation
is done elsewhere by a more testable class.
*/

import 'package:flutter/material.dart';
import 'package:voice_training_app/voice_analyzer.dart';

/*
A stateful widget's state. Contains a vocal analyzer that does
all the real work.
*/
class AnalysisPageState extends State<AnalysisPage> {
  VoiceAnalyzer? analyzer;

  @override
  Widget build(BuildContext context) {
    analyzer = VoiceAnalyzer();
    analyzer?.beginSnapshots((snapshot) {
      // If we have a local instance of the display widget, we
      // can directly call refresh in this lambda. All timing
      // will be handled elsewhere.
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

// The page to be opened from the main screen.
class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key}) : title = "Analysis";
  final String title;

  @override
  State<StatefulWidget> createState() {
    return AnalysisPageState();
  }
}
