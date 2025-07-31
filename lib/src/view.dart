import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../track_maker.dart';

class TrackView extends StatefulWidget {
  const TrackView({
    super.key,
    required this.tracks,
    this.controller,
    this.cacheExtent,
    this.verticalAlignment = 0.5,
  });

  final List<Track> tracks;
  final double? cacheExtent;
  final TrackController? controller;
  final double verticalAlignment;

  @override
  State<TrackView> createState() => _TrackViewState();
}

class _TrackViewState extends State<TrackView> {
  TrackController get controller => _controller!;
  TrackController? _controller;

  double scaleRatio = 10;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TrackController();
  }

  @override
  void didUpdateWidget(TrackView oldWidget) {
    super.didUpdateWidget(oldWidget);

    assert(_controller != null);
    if (oldWidget.controller == null && widget.controller != null) {
      _controller = widget.controller;
    } else if (oldWidget.controller != null && widget.controller == null) {
      assert(oldWidget.controller == _controller);
      _controller = TrackController();
    } else if (oldWidget.controller != widget.controller) {
      assert(oldWidget.controller != null);
      assert(widget.controller != null);
      assert(oldWidget.controller == _controller);
      _controller = widget.controller;
    }
    assert(_controller != null);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is! PointerScaleEvent) return;
        scaleRatio /= event.scale;
        setState(() {});
      },
      child: _TrackView(
        verticalAlignment: widget.verticalAlignment,
        scaleRatio: scaleRatio,
        tracksData: widget.tracks,
        cacheExtent: widget.cacheExtent,
        nodeBuilder: (context, vicinity) {
          final trackItem =
              widget.tracks[vicinity.yIndex].items[vicinity.xIndex];

          return trackItem.build(context);
        },
      ),
    );
  }
}

class _TrackView extends TwoDimensionalScrollView {
  _TrackView({
    required this.scaleRatio,
    required this.tracksData,
    required this.verticalAlignment,
    super.cacheExtent,
    super.horizontalDetails,
    super.verticalDetails,
    required TwoDimensionalIndexedWidgetBuilder nodeBuilder,
    bool addAutomaticKeepAlives = true,
  }) : assert(verticalDetails.direction == AxisDirection.down),
       assert(horizontalDetails.direction == AxisDirection.right),
       super(
         delegate: TrackItemDelegate(
           nodeBuilder: nodeBuilder,
           addAutomaticKeepAlives: addAutomaticKeepAlives,
           addRepaintBoundaries: false,
         ),
       );

  final double scaleRatio;
  final List<Track> tracksData;
  final double verticalAlignment;

  @override
  TrackViewport buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TrackViewport(
      scaleRatio: scaleRatio,
      tracksData: tracksData,
      verticalAlignment: verticalAlignment,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      delegate: delegate as TrackItemDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

class TrackViewport extends TwoDimensionalViewport {
  const TrackViewport({
    super.key,
    required this.scaleRatio,
    required this.tracksData,
    required super.verticalOffset,
    super.verticalAxisDirection = AxisDirection.down,
    required super.horizontalOffset,
    super.horizontalAxisDirection = AxisDirection.right,
    required TrackItemDelegate super.delegate,
    super.cacheExtent,
    super.clipBehavior,
    required this.verticalAlignment,
  }) : super(mainAxis: Axis.vertical);

  final double scaleRatio;
  final List<Track> tracksData;
  final double verticalAlignment;

  @override
  RenderTrackViewport createRenderObject(BuildContext context) {
    return RenderTrackViewport(
      scaleRatio: scaleRatio,
      tracksData: tracksData,
      verticalAlignment: verticalAlignment,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      delegate: delegate as TrackItemDelegate,
      childManager: context as TwoDimensionalChildManager,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTrackViewport renderObject,
  ) {
    renderObject
      ..scaleRatio = scaleRatio
      ..tracksData = tracksData
      ..verticalAlignment = verticalAlignment
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior
      ..delegate = delegate as TrackItemDelegate;
  }
}
