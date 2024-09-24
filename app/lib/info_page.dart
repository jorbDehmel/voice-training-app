import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key}) : title = "Information";
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
