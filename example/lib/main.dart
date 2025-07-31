import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:track_maker/track_maker.dart';

import 'wave.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final soloud = SoLoud.instance;
  await soloud.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyTrackItem extends TrackItem {
  const MyTrackItem({
    required super.startOffset,
    required super.duration,
    required this.name,
    required this.path,
  });

  final String name;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF004D52),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: UnconstrainedBox(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.hardEdge,
                child: Row(
                  spacing: 6,
                  children: [_buildText('$name.wav'), _buildText('$duration')],
                ),
              ),
            ),
            Expanded(
              child: WaveView(
                path: path,
                paintMarkCount: duration.inMilliseconds ~/ 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        color: Color.fromRGBO(255, 255, 255, 0.12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, color: Colors.white),
          maxLines: 1,
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TrackView(
        cacheExtent: 50,
        tracks: [
          const Track(
            height: 100,
            items: [
              MyTrackItem(
                startOffset: Duration.zero,
                duration: Duration(milliseconds: 10100),
                name: 'Famous - Kanye West',
                path: 'assets/samples-famous_86bpm.wav',
              ),
            ],
          ),
          const Track(
            items: [
              MyTrackItem(
                startOffset: Duration(seconds: 1),
                duration: Duration(milliseconds: 3300),
                name: 'Metro Boomin Tag',
                path: 'assets/metro-boomin-tag_E_major.wav',
              ),
            ],
          ),
          Track(
            items: List.generate(
              20,
              (index) => MyTrackItem(
                name: 'rim shot',
                path: 'assets/dry-rim-shot.wav',
                startOffset: Duration(milliseconds: (index * 500) + 200),
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ),
          Track(
            items: List.generate(
              20,
              (index) => MyTrackItem(
                name: 'hi-hat',
                path: 'assets/short-drum-nice-hi-hat.wav',
                startOffset: Duration(milliseconds: index * 500),
                duration: const Duration(milliseconds: 400),
              ),
            ),
          ),
          Track(
            items: List.generate(
              20,
              (index) => MyTrackItem(
                name: 'hi-hat',
                path: 'assets/short-drum-nice-hi-hat.wav',
                startOffset: Duration(milliseconds: (index * 500) + 400),
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
