/*
The home page of the voice training app. This lets the user
move to other pages, but not much else.
*/

import 'package:flutter/material.dart';
import './analysis_page.dart';
import './passthrough_page.dart';
import './info_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectionID = 0;

  static const List<Widget> _subscreens = <Widget>[
    Center(child: AnalysisPage()),
    Center(child: PassthroughPage()),
    Center(child: InfoPage()),
  ];

  void _onMenuClick(int selection) {
    setState(() {
      _selectionID = selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Training'),
      ),
      // Main content window: changes based on the selected index
      body: _subscreens[_selectionID],

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Passthrough',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Info',
          ),
        ],
        currentIndex: _selectionID,
        selectedItemColor: Colors.blue,
        onTap: _onMenuClick,
      ),
    );
  }
}
