
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:typed_data';
import 'dart:async';

import '../../../domain/entities/card.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}


class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late TextRecognizer _textRecognizer;
  String _recognizedText = "";
  bool _isCardDetected = false;
  String cardNumber = "";
  String expiryDate = "";
  final double aspectRatio = 85.60 / 53.98;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();

    _initializeControllerFuture.then((_) {
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      _startImageStream();
    }).catchError((e) {
      print("Error initializing camera: $e");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _startImageStream() async {
    try {
      if (_controller.value.isInitialized) {
        _controller.startImageStream((CameraImage image) async {
          final inputImage = await convertCameraImageToInputImage(image);
          final recognizedText = await _textRecognizer.processImage(inputImage);
          _processRecognizedText(recognizedText);

          if (_isCardDetected) {
            _stopImageStream();
            Navigator.pop(context, CreditCard(cardNumber: cardNumber, expiryDate: expiryDate));
          }
        });
      } else {
        print("Camera is not initialized yet.");
      }
    } catch (e) {
      print("Error starting image stream: $e");
    }
  }

  void _stopImageStream() {
    _controller.stopImageStream();
  }

  InputImage convertCameraImageToInputImage(CameraImage cameraImage) {
    final imageBytes = _concatenatePlanes(cameraImage.planes);
    final inputImage = InputImage.fromBytes(
      bytes: imageBytes,
      metadata: InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: InputImageRotation.rotation270deg,
        format: InputImageFormat.nv21,
        bytesPerRow: 1280,
      ),
    );

    return inputImage;
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

  void _processRecognizedText(RecognizedText recognizedText) {
    String cardNum = "";
    String expiry = "";

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String lineText = line.text;

        if (RegExp(r'\d{4} \d{4} \d{4} \d{4}').hasMatch(lineText)) {
          cardNum = lineText;
        }
        if (RegExp(r'\d{2}/\d{2}').hasMatch(lineText)) {
          expiry = lineText;
        }
      }
    }

    setState(() {
      cardNumber = cardNum;
      expiryDate = expiry;
      _isCardDetected = cardNumber.isNotEmpty && expiryDate.isNotEmpty;
      _recognizedText = recognizedText.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width - 64;
    double cardHeight = cardWidth / aspectRatio;

    return Scaffold(
      appBar: AppBar(title: Text("Card Scanner")),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              CameraPreview(_controller),
              Center(
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 4.0,
                    ),
                  ),
                ),
              ),
              // Display the recognized text in real-time
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.black.withOpacity(0.5),
                  child: SingleChildScrollView(
                    child: Text(
                      _recognizedText.isEmpty
                          ? "No text recognized yet."
                          : _recognizedText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
