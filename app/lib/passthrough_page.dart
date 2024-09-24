import 'package:flutter/material.dart';

class PassthroughPage extends StatelessWidget {
  const PassthroughPage({super.key}) : title = "Microphone Passthrough";
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
