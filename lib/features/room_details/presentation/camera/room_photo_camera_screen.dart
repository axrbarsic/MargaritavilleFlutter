import 'package:flutter/material.dart';

import '../../../../shared/media/capture/photo_camera_session.dart';
import '../../../../shared/media/capture/photo_preview_geometry.dart';
import '../../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';

final class RoomPhotoCameraScreen extends StatefulWidget {
  const RoomPhotoCameraScreen({
    this.sessionFactory = CameraPhotoCameraSession.open,
    super.key,
  });

  final PhotoCameraSessionFactory sessionFactory;

  @override
  State<RoomPhotoCameraScreen> createState() => _RoomPhotoCameraScreenState();
}

final class _RoomPhotoCameraScreenState extends State<RoomPhotoCameraScreen>
    with WidgetsBindingObserver {
  PhotoCameraSession? _session;
  String? _error;
  bool _capturing = false;
  bool _cameraActive = true;
  bool _disposed = false;
  Future<void> _cameraOperations = Future<void>.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enqueue(_openSession);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cameraActive = true;
      _enqueue(_openSession);
    } else {
      _cameraActive = false;
      final session = _detachSession();
      _enqueue(() => _closeSession(session));
    }
  }

  void _enqueue(Future<void> Function() operation) {
    _cameraOperations = _cameraOperations.then((_) => operation()).catchError((
      Object _,
      StackTrace _,
    ) {
      if (!_disposed && mounted) {
        setState(() => _error = 'Камера недоступна');
      }
    });
  }

  Future<void> _openSession() async {
    if (_disposed || !_cameraActive || _session != null) return;
    if (mounted) setState(() => _error = null);
    try {
      final session = await widget.sessionFactory();
      if (_disposed || !_cameraActive || !mounted) {
        await session.dispose();
        return;
      }
      setState(() => _session = session);
    } on PhotoCameraFailure catch (failure) {
      if (!_disposed && _cameraActive && mounted) {
        setState(() => _error = _message(failure.code));
      }
    } catch (_) {
      if (!_disposed && _cameraActive && mounted) {
        setState(() => _error = 'Камера недоступна');
      }
    }
  }

  PhotoCameraSession? _detachSession() {
    final session = _session;
    _session = null;
    if (!_disposed && mounted) setState(() {});
    return session;
  }

  Future<void> _closeSession(PhotoCameraSession? session) async {
    await session?.dispose();
  }

  Future<void> _capture() async {
    final session = _session;
    if (session == null || _capturing) return;
    setState(() {
      _capturing = true;
      _error = null;
    });
    try {
      final result = await session.takePicture();
      if (mounted) Navigator.pop(context, result);
    } on PhotoCameraFailure catch (failure) {
      if (mounted) {
        setState(() {
          _capturing = false;
          _error = _message(failure.code);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _capturing = false;
          _error = 'Не удалось сохранить фото';
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final session = _session;
    _session = null;
    _disposed = true;
    _cameraActive = false;
    _enqueue(() => _closeSession(session));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (session != null) _Preview(session: session),
          if (session == null && _error == null)
            const Center(child: CircularProgressIndicator()),
          if (_error case final error?)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  error,
                  key: const Key('photo-camera-error'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                key: const Key('photo-camera-close'),
                onPressed: () =>
                    MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                      MargaritavilleInteractionIntent.deselect,
                      () => Navigator.pop(context),
                    ),
                icon: const Icon(Icons.close_rounded),
                color: Colors.white,
                iconSize: 28,
                style: IconButton.styleFrom(
                  fixedSize: const Size(48, 48),
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
          if (session != null)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: IconButton(
                    key: const Key('photo-camera-shutter'),
                    onPressed: _capturing
                        ? null
                        : () =>
                              MargaritavilleFeedbackScope.dispatcherOf(
                                context,
                              ).acceptAsyncOnce(
                                'photo-camera-capture',
                                MargaritavilleInteractionIntent.confirm,
                                _capture,
                              ),
                    icon: _capturing
                        ? const SizedBox.square(
                            dimension: 28,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : const Icon(Icons.camera_alt_rounded),
                    color: Colors.black,
                    iconSize: 34,
                    style: IconButton.styleFrom(
                      fixedSize: const Size(72, 72),
                      backgroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _message(PhotoCameraFailureCode code) => switch (code) {
    PhotoCameraFailureCode.denied ||
    PhotoCameraFailureCode.restricted => 'Нет доступа к камере',
    PhotoCameraFailureCode.unavailable => 'Камера недоступна',
    PhotoCameraFailureCode.captureFailed => 'Не удалось сохранить фото',
  };
}

final class _Preview extends StatelessWidget {
  const _Preview({required this.session});

  final PhotoCameraSession session;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = photoPreviewCoverScale(
        rawAspectRatio: session.previewAspectRatio,
        viewport: Size(constraints.maxWidth, constraints.maxHeight),
      );
      return ClipRect(
        child: Transform.scale(
          scale: scale,
          child: Center(child: session.buildPreview()),
        ),
      );
    },
  );
}
