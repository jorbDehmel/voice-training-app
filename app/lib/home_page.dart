import 'package:flutter/material.dart';

import './analysis_page.dart';
import './passthrough_page.dart';
import './gamification_page.dart';
import './info_page.dart';

class VoiceAppHomePage extends StatelessWidget {
  const VoiceAppHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Navigation column
        child: Column(children: [
          // Jump to analysis page
          ElevatedButton(
            child: const Text('Analysis'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalysisPage()),
              );
            },
          ),
          // Jump to passthrough page
          ElevatedButton(
            child: const Text('Passthrough'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PassthroughPage()),
              );
            },
          ),
          // Jump to gamification page
          ElevatedButton(
            child: const Text('Gamification'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GamificationPage()),
              );
            },
          ),
          // Jump to info page
          ElevatedButton(
            child: const Text('Info'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoPage()),
              );
            },
          ),
        ]),
      ),
    );
  }
}
