import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_soloud/flutter_soloud.dart';

import 'async_queue.dart';

class WaveView extends StatelessWidget {
  const WaveView({super.key, required this.path, required this.paintMarkCount});

  final int paintMarkCount;
  final String path;

  static final Map<String, Future<Float32List>> _waveCache = {};
  static final AsyncQueue _waveQueue = AsyncQueue();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: () {
        return _waveQueue.add(() {
          if (_waveCache.containsKey(path)) {
            return _waveCache[path]!;
          }
          return _waveCache[path] = _loadWave(path);
        });
      }(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CustomPaint(
            size: Size.infinite,
            painter: WavePainter(data: snapshot.data!),
          );
        }
        return Text('${snapshot.data ?? snapshot.error}');
      },
    );
  }

  Future<Float32List> _loadWave(String path) async {
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();
    final result = await SoLoud.instance.readSamplesFromMem(
      bytes,
      paintMarkCount,
      // average: true,
    );

    return result;
  }
}

class WavePainter extends CustomPainter {
  const WavePainter({required this.data});

  final Float32List data;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / data.length;
    final paintWidth = min(1.0, barWidth);
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = paintWidth;

    for (var i = 0; i < data.length; i++) {
      final barHeight = size.height * data[i] * 2;

      canvas.drawLine(
        Offset(barWidth * i, (size.height - barHeight) / 2),
        Offset(barWidth * i, (size.height + barHeight) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return true;
  }
}
