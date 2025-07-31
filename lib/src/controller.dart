import 'package:flutter/widgets.dart';

class TrackController {
  TrackController({double initialScaleRatio = 10.0})
    : _scaleRatio = ValueNotifier(initialScaleRatio);

  /// 缩放比例，表示1像素展示多少毫秒
  ValueNotifier<double> get scaleRatio => _scaleRatio;
  final ValueNotifier<double> _scaleRatio;

  /// 设置缩放比例
  void setScaleRatio(double ratio) {
    _scaleRatio.value = ratio.clamp(1.0, 100.0); // 限制缩放范围
  }

  /// 通过缩放因子调整缩放比例
  void scale(double scaleFactor) {
    final newRatio = _scaleRatio.value / scaleFactor;
    setScaleRatio(newRatio);
  }

  void dispose() {
    _scaleRatio.dispose();
  }
}
