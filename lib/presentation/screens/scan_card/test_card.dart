import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../core/service/camera_service.dart';
import '../../../core/service/card_text_recognition_service.dart';
import '../../../core/service/locator.dart';
import '../../widgets/card_painter.dart';

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key});

  @override
  _ScanCardScreenState createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> {
  Size? imageSize;
  bool _initializing = false;
  final double aspectRatio = 85.60 / 53.98;

  final CardTextRecognitionService _cardTextRecognaitionService =
      locator<CardTextRecognitionService>();
  final CameraService _cameraService = locator<CameraService>();

  String  cardNumber = "";
  String  expiryDate = "";

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  _start() async {
    setState(() => _initializing = true);
    await _cameraService.initialize();
    setState(() => _initializing = false);

    _frameFaces();
  }

  _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController?.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        try {
          final details = await _cardTextRecognaitionService.extractCardDetails(
              image, InputImageRotation.rotation0deg,);

          if (details['cardNumber']!.isNotEmpty &&
              details['expiryDate']!.isNotEmpty) {
            // print('Karta raqami: ${details['cardNumber']}');
            // print('Amal qilish muddati: ${details['expiryDate']}');
            // LogService.e('Karta raqami: ${details['cardNumber']}');
            // LogService.d('Karta raqami: ${details['cardNumber']}');
              setState(() {
                cardNumber = details['cardNumber']!;
                expiryDate = details['expiryDate']!;
              });
              //
              // await _cameraService.cameraController?.stopImageStream();
              //
              // Future.delayed(const Duration(seconds: 5), () {
              //   Navigator.pop(context, {'cardNumber': cardNumber, 'expiryDate': expiryDate});
              // });
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double cardWidth = MediaQuery.of(context).size.width - 64;
    double cardHeight = cardWidth / aspectRatio;

    late Widget body;
    if (_initializing) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_initializing) {
      body = Transform.scale(
        scale: 1.0,
        child: AspectRatio(
          aspectRatio: MediaQuery.of(context).size.aspectRatio,
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Container(
                width: width,
                height:
                    width * _cameraService.cameraController!.value.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CameraPreview(_cameraService.cameraController!),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
        body: Stack(
      children: [
        body,
        CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: CardOverlayPainter(cardWidth: cardWidth, cardHeight: cardHeight),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text(
              "Kartani ekranning o'rtasiga joylashtiring",
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(
              cardNumber,
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                // Harakatni bajarish uchun
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text(
                "Qo'l bilan kiritish",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ],
    ));
  }
}
