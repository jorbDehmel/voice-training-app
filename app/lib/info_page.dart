/*
Provides some information about the app and its development.
*/

import 'package:flutter/material.dart';

const String textInfo =
    'This software was developed as a learning exercise at a public '
    'University. It is free and open-source, and is licensed under the MIT '
    'software license. Evelyn Drollinger-Smith, Jordan Dehmel, Emerson Morris. '
    'Under the direction of Dr. Warren MacEvoy at Colorado Mesa University. '
    'Fall 2024.';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key}) : title = "Information";
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        )),
        body: const Column(children: [
          Center(child: Text(textInfo)),
        ]));
  }
}
