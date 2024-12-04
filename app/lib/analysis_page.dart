import 'dart:async';
import 'dart:math';
import 'package:voice_training_app/vocal_stats.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'voice_analyzer.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  AnalysisPageState createState() => AnalysisPageState();
}

class AnalysisPageState extends State<AnalysisPage> {
  ui.Image? _icon;
  double x = 0;
  double y = 0;
  VoiceAnalyzer? analyzer;
  Color status = Colors.red;
  late SendPort sendPort;

  @override
  void initState() {
    super.initState();
    _loadIcon();

    analyzer = VoiceAnalyzer();
    analyzer?.beginSnapshots(0.01, (VocalStats snapshot) {
      setState(() {
        status = Colors.green;

        if (snapshot.averagePitch < 0.0 || snapshot.resonanceMeasure < 0.0) {
          return;
        }

        print('F0: ${snapshot.averagePitch}');
        print('F1: ${snapshot.resonanceMeasure}');

        x = snapshot.averagePitch / 500.0;
        y = snapshot.resonanceMeasure / 15000.0;

        x = min(x, 1);
        y = min(y, 1);
        x = max(x, 0);
        y = max(y, 0);

        y = 1 - y;
      });
    });

    //   workerManager.executeWithPort<void, VocalStats>((SendPort sendPort) async {
    //   VoiceAnalyzer a = VoiceAnalyzer();
    //   a.beginSnapshots(0.01, (VocalStats snapshot) {
    //     List<double> l = [snapshot.averagePitch, snapshot.resonanceMeasure];
    //     sendPort.send(l);
    //   });
    // }, onMessage: (VocalStats message) {
    //   setState(() {
    //     x = message.averagePitch;
    //     y = message.resonanceMeasure;
    //     status = Colors.green;
    //   });
    // });
  }

  Future<void> _loadIcon() async {
    final completer = Completer<ui.Image>();
    final ImageStream stream =
        const AssetImage('assets/icon.png').resolve(const ImageConfiguration());
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
        title: const Text('Graph with Icon'),
      ),
      body: CustomPaint(
        painter: GraphPainter(x: x, y: y, iconImage: _icon, status: status),
        child: Container(),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final double x;
  final double y;
  final ui.Image? iconImage;
  final Color status;

  GraphPainter(
      {required this.x,
      required this.y,
      required this.iconImage,
      required this.status});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = status
      ..strokeWidth = 2;

    // Draw X-axis
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Draw Y-axis
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);

    // Draw the icon if it's loaded
    if (iconImage != null) {
      const iconSize = 30.0; // Set a fixed icon size
      final dstRect = Rect.fromCenter(
          center: Offset(x * size.width, y * size.height),
          width: iconSize,
          height: iconSize);
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
