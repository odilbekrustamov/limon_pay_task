import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardTextRecognitionService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final double aspectRatio = 85.60 / 53.98;

  Future<Map<String, String>> extractCardDetails(CameraImage image, InputImageRotation rotation) async {
    try {
      final inputImage = _convertCameraImageToInputImage(image, rotation);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      _logRecognizedText(recognizedText);

      final centerCrop = _calculateCenterCrop(image);

      return _extractDetailsFromText(recognizedText, centerCrop);
    } catch (e) {
      debugPrint("Error during text recognition: $e");
      return {'cardNumber': '', 'expiryDate': ''};
    }
  }

  void dispose() => _textRecognizer.close();


  InputImage _convertCameraImageToInputImage(CameraImage image, InputImageRotation rotation) {
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

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final length = planes.fold(0, (prev, element) => prev + element.bytes.length);
    final bytes = Uint8List(length);
    int offset = 0;

    for (var plane in planes) {
      bytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }

    return bytes;
  }

  Rect _calculateCenterCrop(CameraImage image) {
    return Rect.fromCenter(
      center: Offset(image.width / 2, image.height / 2),
      width: image.height.toDouble() / aspectRatio,
      height: image.height.toDouble(),
    );
  }

  void _logRecognizedText(RecognizedText recognizedText) {
    debugPrint('Recognized Text: ${recognizedText.text}');
  }

  Map<String, String> _extractDetailsFromText(RecognizedText recognizedText, Rect centerCrop) {
    String cardNumber = '';
    String expiryDate = '';

    for (final block in recognizedText.blocks) {
      if (!centerCrop.contains(_getBlockCenter(block))) continue;

      for (final line in block.lines) {
        final lineText = line.text;

        if (_isCardNumber(lineText)) cardNumber = lineText;
        if (_isExpiryDate(lineText)) expiryDate = lineText;
      }
    }

    return {'cardNumber': cardNumber, 'expiryDate': expiryDate};
  }

  Offset _getBlockCenter(TextBlock block) {
    final boundingBox = block.boundingBox;
    return Offset(
      boundingBox.left + boundingBox.width / 2,
      boundingBox.top + boundingBox.height / 2,
    );
  }

  bool _isCardNumber(String text) => RegExp(r'\d{4} \d{4} \d{4} \d{4}').hasMatch(text);

  bool _isExpiryDate(String text) => RegExp(r'\d{2}/\d{2}').hasMatch(text);
}
