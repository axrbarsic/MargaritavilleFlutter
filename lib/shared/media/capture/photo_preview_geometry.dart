import 'dart:math' as math;

import 'package:flutter/widgets.dart';

double orientedPhotoPreviewAspectRatio({
  required double rawAspectRatio,
  required Size viewport,
}) {
  _validate(rawAspectRatio: rawAspectRatio, viewport: viewport);
  final previewIsPortrait = rawAspectRatio < 1;
  final viewportIsPortrait = viewport.height > viewport.width;
  return previewIsPortrait == viewportIsPortrait
      ? rawAspectRatio
      : 1 / rawAspectRatio;
}

double photoPreviewCoverScale({
  required double rawAspectRatio,
  required Size viewport,
}) {
  final orientedRatio = orientedPhotoPreviewAspectRatio(
    rawAspectRatio: rawAspectRatio,
    viewport: viewport,
  );
  final viewportRatio = viewport.width / viewport.height;
  return math.max(orientedRatio / viewportRatio, viewportRatio / orientedRatio);
}

void _validate({required double rawAspectRatio, required Size viewport}) {
  if (!rawAspectRatio.isFinite || rawAspectRatio <= 0) {
    throw ArgumentError.value(
      rawAspectRatio,
      'rawAspectRatio',
      'Должно быть конечным положительным числом',
    );
  }
  if (!viewport.width.isFinite ||
      !viewport.height.isFinite ||
      viewport.width <= 0 ||
      viewport.height <= 0) {
    throw ArgumentError.value(
      viewport,
      'viewport',
      'Обе стороны должны быть конечными положительными числами',
    );
  }
}
