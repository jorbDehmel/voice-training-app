/*
Flutter's entry point; It just launches the app as defined
elsewhere.
*/

import 'package:flutter/material.dart';
import './home_page.dart';

void main() {
  runApp(const VoiceApp());
}

class VoiceApp extends StatelessWidget {
  const VoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VoiceAppHomePage(title: 'Voice App Home Page'),
    );
  }
}
