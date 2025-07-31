import 'package:flutter/material.dart';
import 'package:track_maker/track_maker.dart';

void main() {
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
  });

  final String name;

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
                  children: [
                    _buildText('$name.mp4'),
                    _buildText(duration.toSecondString()),
                  ],
                ),
              ),
            ),
            const ColoredBox(
              color: Colors.red,
              child: SizedBox(height: 20, width: double.infinity),
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

extension on Duration {
  String toSecondString() {
    var microseconds = inMicroseconds;
    var sign = '';
    final negative = microseconds < 0;

    var hours = microseconds ~/ Duration.microsecondsPerHour;
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);

    // Correcting for being negative after first division, instead of before,
    // to avoid negating min-int, -(2^31-1), of a native int64.
    if (negative) {
      hours = 0 - hours; // Not using `-hours` to avoid creating -0.0 on web.
      microseconds = 0 - microseconds;
      sign = '-';
    }

    final hoursPadding = hours < 10 ? '0' : '';

    final minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);

    final minutesPadding = minutes < 10 ? '0' : '';

    final seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);

    final secondsPadding = seconds < 10 ? '0' : '';

    final milliseconds_10 =
        (microseconds * 10) ~/ Duration.microsecondsPerMillisecond;
    final milliseconds10Padding = milliseconds_10 < 10 ? '0' : '';

    return '$sign$hoursPadding$hours:'
        '$minutesPadding$minutes:'
        '$secondsPadding$seconds:'
        '$milliseconds10Padding$milliseconds_10';
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TrackView(
        cacheExtent: 50,
        tracks: [
          // 主背景音乐轨道
          Track(
            items: [
              MyTrackItem(
                name: '背景音乐-主旋律',
                startOffset: Duration.zero,
                duration: Duration(seconds: 45),
              ),
              MyTrackItem(
                name: '背景音乐-结尾',
                startOffset: Duration(seconds: 50),
                duration: Duration(seconds: 30),
              ),
            ],
          ),

          // 开场白音轨
          Track(
            items: [
              MyTrackItem(
                name: '开场问候',
                startOffset: Duration(milliseconds: 200),
                duration: Duration(seconds: 8),
              ),
              MyTrackItem(
                name: '主题介绍',
                startOffset: Duration(seconds: 12),
                duration: Duration(seconds: 15),
              ),
              MyTrackItem(
                name: '总结回顾',
                startOffset: Duration(seconds: 35),
                duration: Duration(seconds: 6),
              ),
            ],
          ),

          // 音效轨道
          Track(
            items: [
              MyTrackItem(
                name: '鼓掌声',
                startOffset: Duration(seconds: 8),
                duration: Duration(milliseconds: 800),
              ),
              MyTrackItem(
                name: '鼓掌声',
                startOffset: Duration(milliseconds: 8800),
                duration: Duration(milliseconds: 800),
              ),
              MyTrackItem(
                name: '鼓掌声',
                startOffset: Duration(milliseconds: 9600),
                duration: Duration(milliseconds: 800),
              ),
              MyTrackItem(
                name: '钟声',
                startOffset: Duration(seconds: 27),
                duration: Duration(milliseconds: 1200),
              ),
              MyTrackItem(
                name: '按键音',
                startOffset: Duration(seconds: 41),
                duration: Duration(milliseconds: 500),
              ),
              MyTrackItem(
                name: '结束铃声',
                startOffset: Duration(seconds: 55),
                duration: Duration(milliseconds: 900),
              ),
            ],
          ),

          // 采访音轨
          Track(
            items: [
              MyTrackItem(
                name: '嘉宾自我介绍',
                startOffset: Duration(seconds: 15),
                duration: Duration(seconds: 4),
              ),
              MyTrackItem(
                name: '专业观点分享',
                startOffset: Duration(seconds: 22),
                duration: Duration(seconds: 7),
              ),
              MyTrackItem(
                name: '经验总结',
                startOffset: Duration(seconds: 32),
                duration: Duration(seconds: 9),
              ),
            ],
          ),

          // 环境声轨道
          Track(
            items: [
              MyTrackItem(
                name: '办公室环境音',
                startOffset: Duration(seconds: 10),
                duration: Duration(seconds: 25),
              ),
              MyTrackItem(
                name: '咖啡厅环境音',
                startOffset: Duration(seconds: 42),
                duration: Duration(seconds: 20),
              ),
            ],
          ),

          // 片头音乐
          Track(
            items: [
              MyTrackItem(
                name: '片头主题音乐',
                startOffset: Duration(milliseconds: 50),
                duration: Duration(seconds: 3),
              ),
            ],
          ),

          // 旁白音轨
          Track(
            items: [
              MyTrackItem(
                name: '节目介绍',
                startOffset: Duration(seconds: 5),
                duration: Duration(seconds: 2),
              ),
              MyTrackItem(
                name: '背景说明',
                startOffset: Duration(seconds: 18),
                duration: Duration(seconds: 3),
              ),
              MyTrackItem(
                name: '过渡解说',
                startOffset: Duration(seconds: 29),
                duration: Duration(seconds: 2),
              ),
              MyTrackItem(
                name: '结尾致谢',
                startOffset: Duration(seconds: 43),
                duration: Duration(seconds: 4),
              ),
            ],
          ),

          // 转场音效
          Track(
            items: [
              MyTrackItem(
                name: '淡入音效',
                startOffset: Duration(seconds: 7),
                duration: Duration(milliseconds: 300),
              ),
              MyTrackItem(
                name: '切换音效',
                startOffset: Duration(seconds: 21),
                duration: Duration(milliseconds: 600),
              ),
              MyTrackItem(
                name: '过渡音效',
                startOffset: Duration(seconds: 31),
                duration: Duration(milliseconds: 400),
              ),
              MyTrackItem(
                name: '淡出音效',
                startOffset: Duration(seconds: 47),
                duration: Duration(milliseconds: 700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
