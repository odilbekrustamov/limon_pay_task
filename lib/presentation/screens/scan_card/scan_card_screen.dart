
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:async';

import '../../../core/service/camera_service.dart';
import '../../../core/service/card_text_recognition_service.dart';
import '../../../core/service/locator.dart';
import '../../card_details_cubit.dart';
import '../../widgets/card_painter.dart';


class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key});

  @override
  _ScanCardScreenState createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> {
  late CameraService _cameraService;
  late CardTextRecognitionService _cardTextRecognaitionService;

  bool _isInitializing = false;
  bool _textRecognitionStopped = false;

  @override
  void initState() {
    super.initState();
    context.read<CardDetailsCubit>().updateCardDetails(
      "",
      "",
    );

    _cameraService = locator<CameraService>();
    _cardTextRecognaitionService = locator<CardTextRecognitionService>();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _cardTextRecognaitionService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    setState(() => _isInitializing = true);
    await _cameraService.initialize();
    setState(() => _isInitializing = false);
    _startFrameProcessing();
  }

  void _startFrameProcessing() {
    _cameraService.cameraController?.startImageStream((image) async {
      try {
        if(!_textRecognitionStopped){
          final details = await _cardTextRecognaitionService.extractCardDetails(
              image, InputImageRotation.rotation0deg);

          if (details['cardNumber']!.isNotEmpty && details['expiryDate']!.isNotEmpty) {
            _textRecognitionStopped = true;

            context.read<CardDetailsCubit>().updateCardDetails(
              details['cardNumber']!,
              details['expiryDate']!,
            );

            await Future.delayed(const Duration(seconds: 3));

            if (mounted) {
              Navigator.pop(context, {
                'cardNumber': details['cardNumber']!,
                'expiryDate': details['expiryDate']!,
              });
            }
          }
        }
      } catch (e) {
        debugPrint("Error during text recognition: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width - 64;
    final cardHeight = cardWidth / (85.60 / 53.98);

    return Scaffold(
      body: Stack(
        children: [
          _buildCameraPreview(),
          _buildCardOverlay(cardWidth, cardHeight),
          _buildUI(cardWidth, cardHeight),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    final previewSize = _cameraService.cameraController?.value.previewSize;
    if (previewSize == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final aspectRatio = previewSize.height / previewSize.width;

    return Transform.scale(
      scale: 1.0,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: CameraPreview(_cameraService.cameraController!),
      ),
    );
  }


  Widget _buildCardOverlay(double cardWidth, double cardHeight) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: CardOverlayPainter(cardWidth: cardWidth, cardHeight: cardHeight),
    );
  }

  Widget _buildUI(double cardWidth, double cardHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        const Text(
          "Kartani ekranning o'rtasiga joylashtiring",
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        _buildCardInfo(),
        const Spacer(),
        _buildManualEntryButton(),
        SizedBox(height: 50),
      ],
    );
  }

  Widget _buildCardInfo() {
    return BlocBuilder<CardDetailsCubit, Map<String, String>>(
      builder: (context, state) {
        return Column(
          children: [
            Text(
              state['cardNumber'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Text(
              state['expiryDate'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildManualEntryButton() {
    return ElevatedButton(
      onPressed: () {
        // Manual entry action
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      child: const Text(
        "Qo'l bilan kiritish",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
