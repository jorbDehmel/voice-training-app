import 'dart:async';
import 'package:voice_training_app/vocal_stats.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'voice_analyzer.dart';

class AnalysisPage extends StatefulWidget {
  @override
  AnalysisPageState createState() => AnalysisPageState();
}

class AnalysisPageState extends State<AnalysisPage> {
  ui.Image? _icon;
  double x = 0;
  double y = 0;
  late SendPort sendPort;

  @override
  void initState() {
    super.initState();
    _loadIcon();

    () async {
      await workerManager.init();
    };

    workerManager.executeWithPort<void, VocalStats>(
      (SendPort sendPort) async {
        VoiceAnalyzer a = VoiceAnalyzer();
        a.beginSnapshots(0.01, (VocalStats snapshot) {
          List<double> l = [snapshot.averagePitch, snapshot.resonanceMeasure];
          sendPort.send(l);
        });
      },
      onMessage: (VocalStats message) {
        setState(() {
          x = message.averagePitch;
          y = message.resonanceMeasure;
        });
      },
      priority: WorkPriority.immediately,
    );

    // () async {
    //   await Isolate.spawn(analysisWorkerMain, readPort.sendPort);
    // };

    // readPort.listen((dynamic message) async {
    //   setState(() {
    //     x = message[0];
    //     y = message[1];
    //   });
    // });
  }

  Future<void> _loadIcon() async {
    final completer = Completer<ui.Image>();
    final ImageStream stream =
        AssetImage('assets/icon.png').resolve(ImageConfiguration());
    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));
    _icon = await completer.future;
    setState(() {}); // Force a rebuild once the image is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graph with Icon'),
      ),
      body: CustomPaint(
        painter: GraphPainter(x: x, y: y, iconImage: _icon),
        child: Container(),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final double x;
  final double y;
  final ui.Image? iconImage;

  GraphPainter({required this.x, required this.y, required this.iconImage});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // Draw X-axis
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Draw Y-axis
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);

    // Draw the icon if it's loaded
    if (iconImage != null) {
      final iconSize = 30.0; // Set a fixed icon size
      final dstRect = Rect.fromCenter(
          center: Offset(x, y), width: iconSize, height: iconSize);
      canvas.drawImageRect(
          iconImage!,
          Rect.fromLTWH(
              0, 0, iconImage!.width.toDouble(), iconImage!.height.toDouble()),
          dstRect,
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint as the x, y positions are dynamic
  }
}
