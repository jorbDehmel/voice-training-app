import 'package:flutter/material.dart';
import 'package:voice_training_app/voice_analyzer.dart';

class PassthroughPageState extends State<PassthroughPage> {
  VoiceAnalyzer? analyzer;
  double delay = 0.0;

  @override
  Widget build(BuildContext context) {
    analyzer = VoiceAnalyzer();
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

    analyzer?.beginPlayStreamWithDelay(delay);

    return Scaffold(
        body: Expanded(
            child: Column(children: [
      BackButton(
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      Slider(
        value: delay,
        max: 30.0,
        label: delay.round().toString(),
        onChanged: (double value) {
          setState(() {
            delay = value;
            analyzer?.beginPlayStreamWithDelay(delay);
          });
        },
      ),
    ])));
  }

  @override
  void dispose() {
    analyzer?.dispose();
    analyzer = null;
    super.dispose();
  }
}

class PassthroughPage extends StatefulWidget {
  const PassthroughPage({super.key}) : title = "Microphone Passthrough";
  final String title;

  @override
  State<StatefulWidget> createState() {
    return PassthroughPageState();
  }
}
