import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:limon_pay/data/service/card_text_recognition_service.dart';

import '../../data/service/camera_service.dart';

class ExtractCardDetailsUseCase {
  final CameraService _cameraService;
  final CardTextRecognitionService _recognitionService;

  ExtractCardDetailsUseCase(this._cameraService, this._recognitionService);

  Future<Map<String, String>> execute(CameraImage image) async {

    return await _recognitionService.extractCardDetails(_buildMetaData(image, InputImageRotation.rotation0deg));
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer buffer = WriteBuffer();
    for (final Plane plane in planes) {
      buffer.putUint8List(plane.bytes);
    }
    return buffer.done().buffer.asUint8List();
  }

  InputImage _buildMetaData(CameraImage image, InputImageRotation rotation) {
    final imageBytes = _concatenatePlanes(image.planes);

    return InputImage.fromBytes(
      bytes: imageBytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
}
