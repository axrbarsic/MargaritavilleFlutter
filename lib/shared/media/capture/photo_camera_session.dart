import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

import 'captured_photo_artifact.dart';

enum PhotoCameraFailureCode { denied, restricted, unavailable, captureFailed }

final class PhotoCameraFailure implements Exception {
  const PhotoCameraFailure(this.code, [this.cause]);

  final PhotoCameraFailureCode code;
  final Object? cause;
}

abstract interface class PhotoCameraSession {
  double get previewAspectRatio;

  Widget buildPreview();

  Future<CapturedPhotoArtifact> takePicture();

  Future<void> dispose();
}

typedef PhotoCameraSessionFactory = Future<PhotoCameraSession> Function();

final class CameraPhotoCameraSession implements PhotoCameraSession {
  CameraPhotoCameraSession._(this._controller);

  final CameraController _controller;

  static Future<PhotoCameraSession> open() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw const PhotoCameraFailure(PhotoCameraFailureCode.unavailable);
      }
      final description = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        description,
        ResolutionPreset.max,
        enableAudio: false,
      );
      try {
        await controller.initialize();
        try {
          await controller.setFlashMode(FlashMode.auto);
        } on CameraException {
          // Some cameras expose capture but not an adjustable flash mode.
        }
        return CameraPhotoCameraSession._(controller);
      } catch (_) {
        await controller.dispose();
        rethrow;
      }
    } on PhotoCameraFailure {
      rethrow;
    } on CameraException catch (error) {
      throw PhotoCameraFailure(_mapCameraError(error.code), error);
    } catch (error) {
      throw PhotoCameraFailure(PhotoCameraFailureCode.unavailable, error);
    }
  }

  @override
  double get previewAspectRatio => _controller.value.aspectRatio;

  @override
  Widget buildPreview() => CameraPreview(_controller);

  @override
  Future<CapturedPhotoArtifact> takePicture() async {
    try {
      final capture = await _controller.takePicture();
      final file = File(capture.path);
      final byteLength = await file.length();
      if (byteLength <= 0) {
        throw const PhotoCameraFailure(PhotoCameraFailureCode.captureFailed);
      }
      final extension = _extension(capture.path);
      return CapturedPhotoArtifact(
        transientFilePath: file.absolute.path,
        byteLength: byteLength,
        mimeType: _mimeType(extension),
        fileExtension: extension,
        createdAt: DateTime.now().toUtc(),
      );
    } on PhotoCameraFailure {
      rethrow;
    } on CameraException catch (error) {
      throw PhotoCameraFailure(PhotoCameraFailureCode.captureFailed, error);
    } catch (error) {
      throw PhotoCameraFailure(PhotoCameraFailureCode.captureFailed, error);
    }
  }

  @override
  Future<void> dispose() => _controller.dispose();

  static PhotoCameraFailureCode _mapCameraError(String code) => switch (code) {
    'CameraAccessDenied' ||
    'CameraAccessDeniedWithoutPrompt' => PhotoCameraFailureCode.denied,
    'CameraAccessRestricted' => PhotoCameraFailureCode.restricted,
    _ => PhotoCameraFailureCode.unavailable,
  };

  static String _extension(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return 'jpg';
    return fileName.substring(dot + 1).toLowerCase();
  }

  static String _mimeType(String extension) => switch (extension) {
    'heic' || 'heif' => 'image/heic',
    'png' => 'image/png',
    _ => 'image/jpeg',
  };
}
