import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:async';

import '../../../core/service/camera_service.dart';
import '../../../core/service/card_text_recognition_service.dart';
import '../../../core/service/locator.dart';
import '../../../theme/color.dart';
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
  bool _isProcessing = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    context.read<CardDetailsCubit>().updateCardDetails(
          "",
          "",
        );

    _cameraService = locator<CameraService>();
    _cardTextRecognaitionService = locator<CardTextRecognitionService>();
    _initializeServices();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _cardTextRecognaitionService.dispose();
    super.dispose();
  }

  void _initializeServices() {
    _cameraService = locator<CameraService>();
    _cardTextRecognaitionService = locator<CardTextRecognitionService>();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() => _isInitializing = true);
    await _cameraService.initialize();
    setState(() => _isInitializing = false);
    _startFrameProcessing();
  }

  void _startFrameProcessing() {
    _cameraService.cameraController?.startImageStream((image) async {
      final details = await _recognizeCardDetails(image);
      if (details != null && !_isProcessing) {
        _updateCardDetails(details);
      }
    });
  }

  Future<Map<String, String>?> _recognizeCardDetails(CameraImage image) async {
    try {
      final details = await _cardTextRecognaitionService.extractCardDetails(
          image, InputImageRotation.rotation0deg);
      return details;
    } catch (e) {
      debugPrint("Error during text recognition: $e");
      return null;
    }
  }

  void _updateCardDetails(Map<String, String> details) {
    context.read<CardDetailsCubit>().updateCardDetails(
      details['cardNumber']!,
      details['expiryDate']!,
    );
  }


  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        _buildCameraPreview(),
        _buildCardOverlay(),
        Positioned.fill(
          child: _buildCardInfo(),
        )
      ],
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

    final scale = 1 /
        (_cameraService.cameraController!.value.aspectRatio *
            MediaQuery.of(context).size.aspectRatio);
    return Transform.scale(
      scale: scale,
      alignment: Alignment.topCenter,
      child: CameraPreview(_cameraService.cameraController!),
    );
  }

  Widget _buildCardOverlay() {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width - 64;
    final cardHeight = cardWidth / (85.60 / 53.98);

    return Positioned.fill(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: ShapeDecoration(
          shape: QrScannerOverlayShape(
            borderColor: Colors.white,
            borderRadius: 10,
            borderLength: 20,
            borderWidth: 5,
            cutOutHeight: cardHeight,
            cutOutWidth: cardWidth,
          ),
        ),
      ),
    );
  }

  Widget _buildCardInfo() {
    return BlocBuilder<CardDetailsCubit, Map<String, String>>(
      builder: (context, state) {
        final cardNumber = state['cardNumber'] ?? '';
        final expiryDate = state['expiryDate'] ?? '';
        if (!_isProcessing && cardNumber.isNotEmpty && expiryDate.isNotEmpty) {
          _isProcessing = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                Navigator.pop(context, {
                  'cardNumber': state['cardNumber'] ?? '',
                  'expiryDate': state['expiryDate'] ?? ''
                });
              }
            });
          });
        }
        return Positioned.fill(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  cardNumber,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: white),
                ),
                Text(
                  expiryDate,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
