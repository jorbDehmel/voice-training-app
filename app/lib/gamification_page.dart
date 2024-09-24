import 'package:flutter/material.dart';

class GamificationPage extends StatelessWidget {
  const GamificationPage({super.key}) : title = "Gamification";
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BackButton(
      onPressed: () {
        Navigator.pop(context);
      },
    ));
  }
}
