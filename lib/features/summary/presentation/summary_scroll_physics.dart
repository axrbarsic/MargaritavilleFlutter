import 'package:flutter/material.dart';

ScrollPhysics? summaryScrollPhysicsFor(TargetPlatform platform) {
  if (platform != TargetPlatform.iOS) return null;
  return const BouncingScrollPhysics(
    decelerationRate: ScrollDecelerationRate.normal,
    parent: AlwaysScrollableScrollPhysics(),
  );
}
