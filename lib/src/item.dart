// import 'package:flutter/widgets.dart';

// import 'model.dart';
// import 'view.dart';

// class TrackItemParentData extends TwoDimensionalViewportParentData {
//   TrackItem? trackItem;
// }

// class TrackItemCell extends ParentDataWidget<TrackItemParentData> {
//   const TrackItemCell({
//     super.key,
//     required this.trackItem,
//     required super.child,
//   });

//   final TrackItem trackItem;

//   @override
//   void applyParentData(RenderObject renderObject) {
//     final TrackItemParentData parentData =
//         renderObject.parentData! as TrackItemParentData;
//     bool needsLayout = false;

//     if (parentData.trackItem != trackItem) {
//       parentData.trackItem = trackItem;
//       needsLayout = true;
//     }

//     if (needsLayout) {
//       renderObject.parent?.markNeedsLayout();
//     }
//   }

//   @override
//   Type get debugTypicalAncestorWidgetClass => TrackViewport;
// }
