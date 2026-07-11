/// Camera-produced immutable metadata before app-specific publication.
///
/// App identity, room identity and storage policy deliberately do not belong to
/// this contract. They are attached by the feature application layer.
final class CapturedPhotoArtifact {
  const CapturedPhotoArtifact({
    required this.transientFilePath,
    required this.byteLength,
    required this.mimeType,
    required this.fileExtension,
    required this.createdAt,
    this.widthPixels,
    this.heightPixels,
    this.orientation,
    this.colorSpace,
    this.isHdr,
  });

  final String transientFilePath;
  final int byteLength;
  final String mimeType;
  final String fileExtension;
  final DateTime createdAt;
  final int? widthPixels;
  final int? heightPixels;
  final int? orientation;
  final String? colorSpace;
  final bool? isHdr;
}
