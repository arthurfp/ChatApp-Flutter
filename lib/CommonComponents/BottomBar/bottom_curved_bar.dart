import 'package:flutter/material.dart';

class BackgroundCurvePainter extends CustomPainter {
  static const _topradius = 50.0;
  static const _bottomRadius = 30.0;
  static const _topHorizontalControl = 0.6;
  static const _bottomHorizontalControl = 0.5;
  static const _topPointControl = 0.35;
  static const _bottomPointControl = 0.85;
  static const _yTop = -20.0;
  static const _yBottom = 0.0;
  static const _distanceTop = 0.0;
  static const _distanceBottom = 10.0;

  final double _x;
  final double _normalizedY;
  final Color _color;

  BackgroundCurvePainter(double x, double normalizedY, Color color)
      : _x = x, _normalizedY = normalizedY, _color = color;

  @override
  void paint(canvas, size) {
    // Paint two cubic bezier curves using various linear interpolations based off of the `_normalizedY` value
    final norm = LinearPointCurve(0.5, 2.0).transform(_normalizedY) / 5;

    final radius = Tween<double>(
        begin: _topradius,
        end: _bottomRadius
      ).transform(norm);
    // Point colinear to the top edge of the background pane
    final anchorControlOffset = Tween<double>(
        begin: radius * _topHorizontalControl,
        end: radius * _bottomHorizontalControl
      ).transform(LinearPointCurve(0.5, 0.75).transform(norm));
    // Point that slides up and down depending on distance for the target x position
    final dipControlOffset = Tween<double>(
        begin: radius * _topPointControl,
        end: radius * _bottomPointControl
      ).transform(LinearPointCurve(0.5, 0.8).transform(norm));
    final y = Tween<double>(
        begin: _yTop,
        end: _yBottom
        ).transform(LinearPointCurve(0.2, 0.7).transform(norm));
    final dist = Tween<double>(
        begin: _distanceTop,
        end: _distanceBottom
        ).transform(LinearPointCurve(0.5, 0.0).transform(norm));
    final x0 = _x - dist / 2;
    final x1 = _x + dist / 2;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(x0 - radius, 0)
      ..cubicTo(x0 - radius + anchorControlOffset, 0, x0 - dipControlOffset, y, x0, y)
      ..lineTo(x1, y)
      ..cubicTo(x1 + dipControlOffset, y, x1 + radius - anchorControlOffset, 0, x1 + radius, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    final paint = Paint()
        ..color = _color;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BackgroundCurvePainter oldPainter) {
    return _x != oldPainter._x
        || _normalizedY != oldPainter._normalizedY
        || _color != oldPainter._color;
  }
}

class LinearPointCurve extends Curve {
  final double pIn;
  final double pOut;

  LinearPointCurve(this.pIn, this.pOut);

  @override
  double transform(double x) {
    // Just a simple bit of linear interpolation math
    final lowerScale = pOut / pIn;
    final upperScale = (1.0 - pOut) / (1.0 - pIn);
    final upperOffset = 1.0 - upperScale;
    return x < pIn ? x * lowerScale : x * upperScale + upperOffset;
  }

}
