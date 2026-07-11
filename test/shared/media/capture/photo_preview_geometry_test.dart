import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/media/capture/photo_preview_geometry.dart';

void main() {
  test('portrait viewport orients raw landscape 4:3 as 3:4', () {
    const viewport = Size(430, 932);

    expect(
      orientedPhotoPreviewAspectRatio(
        rawAspectRatio: 4 / 3,
        viewport: viewport,
      ),
      closeTo(3 / 4, 0.000001),
    );
  });

  test('cover scale uses oriented preview ratio without magic coefficient', () {
    const viewport = Size(430, 932);

    final scale = photoPreviewCoverScale(
      rawAspectRatio: 4 / 3,
      viewport: viewport,
    );

    expect(scale, closeTo((3 / 4) / (430 / 932), 0.000001));
    expect(scale, closeTo(1.625581, 0.000001));
  });

  test('landscape viewport keeps landscape ratio', () {
    const viewport = Size(932, 430);

    expect(
      orientedPhotoPreviewAspectRatio(
        rawAspectRatio: 4 / 3,
        viewport: viewport,
      ),
      closeTo(4 / 3, 0.000001),
    );
    expect(
      photoPreviewCoverScale(rawAspectRatio: 4 / 3, viewport: viewport),
      closeTo((932 / 430) / (4 / 3), 0.000001),
    );
  });
}
