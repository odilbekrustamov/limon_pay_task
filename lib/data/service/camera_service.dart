import 'package:camera/camera.dart';

class CameraService {
  CameraController? _cameraController;

  Future<CameraController> initializeCamera() async {
    if (_cameraController != null) return _cameraController!;
    final cameras = await availableCameras();
    final camera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);

    _cameraController = CameraController(camera, ResolutionPreset.high, enableAudio: false);
    await _cameraController!.initialize();
    return _cameraController!;
  }

  Future<void> disposeCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
}
