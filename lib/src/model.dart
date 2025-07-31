import 'package:flutter/widgets.dart';

class Track {
  const Track({required this.items, this.height = 68});

  final double height;
  final List<TrackItem> items;
}

abstract class TrackItem {
  const TrackItem({required this.startOffset, required this.duration});

  final Duration startOffset;
  final Duration duration;

  Duration get endOffset => startOffset + duration;

  Widget build(BuildContext context);
}
