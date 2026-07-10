import 'dart:math' as math;

import 'package:flutter/material.dart';

final class VipJellyShapeClipper extends CustomClipper<Path> {
  const VipJellyShapeClipper({
    required this.seconds,
    required this.speed,
    required this.seed,
    required this.cornerRadius,
  });

  final double seconds;
  final double speed;
  final double seed;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    if (size.isEmpty) return Path();
    final time = seconds * speed.clamp(0.2, 2.5);
    final amplitude = math.min(size.height * 0.22, 18.0);
    final radius = math.min(
      cornerRadius,
      math.min(size.height * 0.46, size.width * 0.12),
    );
    final left = 0.0;
    final right = size.width;
    final top = 0.0;
    final bottom = size.height;
    final path = Path()
      ..moveTo(
        left + radius,
        top + _offset(edge: 0, unit: 0, time: time, amplitude: amplitude),
      );

    _addHorizontalEdge(
      path,
      y: top,
      fromX: left + radius,
      toX: right - radius,
      edge: 0,
      time: time,
      amplitude: amplitude,
    );
    path.quadraticBezierTo(
      right +
          _offset(edge: 4, unit: 0.25, time: time, amplitude: amplitude * 0.55),
      top,
      right,
      top + radius,
    );
    _addVerticalEdge(
      path,
      x: right,
      fromY: top + radius,
      toY: bottom - radius,
      edge: 1,
      time: time,
      amplitude: amplitude,
    );
    path.quadraticBezierTo(
      right,
      bottom +
          _offset(edge: 5, unit: 0.75, time: time, amplitude: amplitude * 0.55),
      right - radius,
      bottom,
    );
    _addHorizontalEdge(
      path,
      y: bottom,
      fromX: right - radius,
      toX: left + radius,
      edge: 2,
      time: time,
      amplitude: amplitude,
    );
    path.quadraticBezierTo(
      left +
          _offset(edge: 6, unit: 0.35, time: time, amplitude: amplitude * 0.55),
      bottom,
      left,
      bottom - radius,
    );
    _addVerticalEdge(
      path,
      x: left,
      fromY: bottom - radius,
      toY: top + radius,
      edge: 3,
      time: time,
      amplitude: amplitude,
    );
    path
      ..quadraticBezierTo(
        left,
        top +
            _offset(
              edge: 7,
              unit: 0.9,
              time: time,
              amplitude: amplitude * 0.55,
            ),
        left + radius,
        top,
      )
      ..close();
    return path;
  }

  void _addHorizontalEdge(
    Path path, {
    required double y,
    required double fromX,
    required double toX,
    required int edge,
    required double time,
    required double amplitude,
  }) {
    const steps = 28;
    final points = <Offset>[
      for (var index = 0; index <= steps; index++)
        Offset(
          fromX + (toX - fromX) * index / steps,
          y +
              _offset(
                edge: edge,
                unit: index / steps,
                time: time,
                amplitude: amplitude,
              ),
        ),
    ];
    _addSmoothEdge(path, points);
  }

  void _addVerticalEdge(
    Path path, {
    required double x,
    required double fromY,
    required double toY,
    required int edge,
    required double time,
    required double amplitude,
  }) {
    const steps = 12;
    final points = <Offset>[
      for (var index = 0; index <= steps; index++)
        Offset(
          x +
              _offset(
                edge: edge,
                unit: index / steps,
                time: time,
                amplitude: amplitude * 0.55,
              ),
          fromY + (toY - fromY) * index / steps,
        ),
    ];
    _addSmoothEdge(path, points);
  }

  void _addSmoothEdge(Path path, List<Offset> points) {
    for (var index = 0; index < points.length - 1; index++) {
      final previous = points[math.max(index - 1, 0)];
      final current = points[index];
      final next = points[index + 1];
      final afterNext = points[math.min(index + 2, points.length - 1)];
      final control1 = current + (next - previous) / 6;
      final control2 = next - (afterNext - current) / 6;
      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        next.dx,
        next.dy,
      );
    }
  }

  double _offset({
    required int edge,
    required double unit,
    required double time,
    required double amplitude,
  }) {
    final edgeSeed = seed * 19.37 + edge * 0.731;
    final slow = math.sin(
      (unit * (1.7 + edgeSeed % 1.9) +
              time * (0.31 + edgeSeed * 0.017) +
              edgeSeed) *
          math.pi *
          2,
    );
    final medium = math.sin(
      (unit * (3.1 + edgeSeed % 2.4) -
              time * (0.47 + seed * 0.09) +
              edgeSeed * 1.41) *
          math.pi *
          2,
    );
    final fast = math.sin(
      (unit * (4.6 + seed * 1.7) +
              time * (0.61 + edge * 0.017) +
              edgeSeed * 2.17) *
          math.pi *
          2,
    );
    final drift = math.sin((time * 0.113 + seed * 8 + edge) * math.pi * 2);
    return (slow * 0.52 + medium * 0.31 + fast * 0.11 + drift * 0.06) *
        amplitude;
  }

  @override
  bool shouldReclip(VipJellyShapeClipper oldClipper) {
    return oldClipper.seconds != seconds ||
        oldClipper.speed != speed ||
        oldClipper.seed != seed ||
        oldClipper.cornerRadius != cornerRadius;
  }
}
