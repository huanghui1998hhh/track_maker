import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../track_maker.dart';

class RenderTrackViewport extends RenderTwoDimensionalViewport
    with _MaxBoundsGetter {
  RenderTrackViewport({
    required double scaleRatio,
    required List<Track> tracksData,
    required double verticalAlignment,
    required super.horizontalOffset,
    super.horizontalAxisDirection = AxisDirection.right,
    required super.verticalOffset,
    super.verticalAxisDirection = AxisDirection.down,
    required TrackItemDelegate super.delegate,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior,
  }) : _scaleRatio = scaleRatio,
       _tracksData = tracksData,
       _verticalAlignment = verticalAlignment,
       super(mainAxis: Axis.horizontal);

  final Map<int, _RowSpan> _rowMetrics = <int, _RowSpan>{};
  int? _firstNonPinnedRow;
  int? _lastNonPinnedRow;

  double get verticalAlignment => _verticalAlignment;
  double _verticalAlignment;
  set verticalAlignment(double value) {
    if (_verticalAlignment == value) {
      return;
    }
    _verticalAlignment = value;
    markNeedsLayout();
  }

  /// 1像素展示多少毫秒
  double get scaleRatio => _scaleRatio;
  double _scaleRatio;
  set scaleRatio(double value) {
    if (_scaleRatio == value) {
      return;
    }
    _scaleRatio = value;
    markNeedsLayout();
  }

  List<Track> get tracksData => _tracksData;
  List<Track> _tracksData;
  set tracksData(List<Track> value) {
    if (_tracksData == value) {
      return;
    }
    _tracksData = value;
    markNeedsLayout();
  }

  @override
  TrackItemDelegate get delegate => super.delegate as TrackItemDelegate;
  @override
  set delegate(TrackItemDelegate value) {
    super.delegate = value;
  }

  void _updateFirstAndLastVisibleCell() {
    _firstNonPinnedRow = null;
    _lastNonPinnedRow = null;
    for (int row = 0; row < _rowMetrics.length; row++) {
      final double endOfRow = _rowMetrics[row]!.trailingOffset;
      if (endOfRow >= targetLeadingRowPixel && _firstNonPinnedRow == null) {
        _firstNonPinnedRow = row;
      }
      if (endOfRow >= targetTrailingRowPixel && _lastNonPinnedRow == null) {
        _lastNonPinnedRow = row;
        break;
      }
    }
    if (_firstNonPinnedRow != null) {
      _lastNonPinnedRow ??= _rowMetrics.length - 1;
    }
  }

  @override
  void layoutChildSequence() {
    if (needsDelegateRebuild || didResize) {
      _updateRowMetrics();
      _updateScrollBounds();
    } else {
      _updateFirstAndLastVisibleCell();
    }

    if (_rowMetrics.isEmpty) return;

    final startBoundOffset = pixelToDuration(targetLeadingColumnPixel);
    final endBoundOffset = pixelToDuration(targetTrailingColumnPixel);
    final isVerticalFull =
        _rowMetrics[_rowMetrics.length - 1]!.trailingOffset >
        viewportDimension.height;
    final allTrackHeight =
        _rowMetrics[_rowMetrics.length - 1]!.trailingOffset -
        _rowMetrics[0]!.leadingOffset;
    final verticalAlignmentOffset = isVerticalFull
        ? 0
        : (viewportDimension.height - allTrackHeight) * _verticalAlignment;

    for (var i = _firstNonPinnedRow!; i <= _lastNonPinnedRow!; i++) {
      final trackData = tracksData[i];
      final rowCount = trackData.items.length;
      for (int j = 0; j < rowCount; j++) {
        final trackItem = trackData.items[j];

        if (trackItem.startOffset >= endBoundOffset) {
          break;
        }

        if (trackItem.endOffset <= startBoundOffset) {
          continue;
        }
        final RenderBox cell = buildOrObtainChildFor(
          ChildVicinity(xIndex: j, yIndex: i),
        )!;

        final parentData = parentDataOf(cell);

        final width = durationToPixel(trackItem.duration);
        final startOffset = durationToPixel(trackItem.startOffset);
        cell.layout(
          BoxConstraints(maxWidth: width, maxHeight: trackData.height),
        );

        final vSpan = _rowMetrics[i]!;

        parentData.layoutOffset = Offset(
          startOffset - horizontalOffset.pixels,
          vSpan.leadingOffset - verticalOffset.pixels + verticalAlignmentOffset,
        );

        if (trackItem.endOffset >= endBoundOffset) {
          break;
        }
      }
    }
  }

  double durationToPixel(Duration duration) =>
      duration.inMilliseconds / scaleRatio;
  Duration pixelToDuration(double pixel) =>
      Duration(milliseconds: (pixel * scaleRatio).round());

  void _updateRowMetrics() {
    double startOfRegularRow = 0.0;
    _firstNonPinnedRow = null;
    _lastNonPinnedRow = null;
    int row = 0;

    while (row != tracksData.length) {
      final double leadingOffset = startOfRegularRow;
      _RowSpan? span = _rowMetrics.remove(row);
      span ??= _RowSpan();
      span.update(leadingOffset: leadingOffset, extent: tracksData[row].height);
      _rowMetrics[row] = span;
      if (span.trailingOffset >= targetLeadingRowPixel &&
          _firstNonPinnedRow == null) {
        _firstNonPinnedRow = row;
      }
      if (span.trailingOffset >= targetTrailingRowPixel &&
          _lastNonPinnedRow == null) {
        _lastNonPinnedRow = row;
      }
      startOfRegularRow = span.trailingOffset;
      row++;
    }
  }

  void _updateScrollBounds() {
    final bool acceptedDimension =
        _updateHorizontalScrollBounds() && _updateVerticalScrollBounds();
    if (!acceptedDimension) {
      _updateFirstAndLastVisibleCell();
    }
  }

  bool _updateHorizontalScrollBounds() {
    Duration maxDuration = Duration.zero;

    for (final trackData in tracksData) {
      for (final trackItem in trackData.items) {
        maxDuration = maxDuration > trackItem.endOffset
            ? maxDuration
            : trackItem.endOffset;
      }
    }

    return horizontalOffset.applyContentDimensions(
      0,
      max(0, durationToPixel(maxDuration) - viewportDimension.width),
    );
  }

  bool _updateVerticalScrollBounds() {
    final double maxVerticalScrollExtent;

    final int lastRow = _rowMetrics.length - 1;
    if (_firstNonPinnedRow != null) {
      _lastNonPinnedRow ??= lastRow;
    }
    maxVerticalScrollExtent = max(
      0.0,
      _rowMetrics[lastRow]!.trailingOffset - viewportDimension.height,
    );
    return verticalOffset.applyContentDimensions(0.0, maxVerticalScrollExtent);
  }
}

class TrackItemDelegate extends TwoDimensionalChildBuilderDelegate {
  TrackItemDelegate({
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    required TwoDimensionalIndexedWidgetBuilder nodeBuilder,
  }) : super(builder: nodeBuilder);
}

class _RowSpan {
  double get leadingOffset => _leadingOffset;
  late double _leadingOffset;

  double get trailingOffset => _leadingOffset + _extent;

  double get extent => _extent;
  late double _extent;

  void update({required double leadingOffset, required double extent}) {
    _leadingOffset = leadingOffset;
    _extent = extent;
  }
}

mixin _MaxBoundsGetter on RenderTwoDimensionalViewport {
  double get targetLeadingColumnPixel {
    return clampDouble(
      horizontalOffset.pixels - cacheExtent,
      0,
      double.infinity,
    );
  }

  double get targetTrailingColumnPixel {
    return cacheExtent + horizontalOffset.pixels + viewportDimension.width;
  }

  double get targetLeadingRowPixel {
    return clampDouble(verticalOffset.pixels - cacheExtent, 0, double.infinity);
  }

  double get targetTrailingRowPixel {
    return cacheExtent + verticalOffset.pixels + viewportDimension.height;
  }
}
