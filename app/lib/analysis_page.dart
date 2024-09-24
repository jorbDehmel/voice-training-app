import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key}) : title = "Analysis";
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
