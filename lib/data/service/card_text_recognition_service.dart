import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardTextRecognitionService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<Map<String, String>> extractCardDetails(InputImage inputImage) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);

    String? cardNumber;
    String? expiryDate;

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        if (RegExp(r'^\d{16}$').hasMatch(line.text)) {
          cardNumber = line.text;
        } else if (RegExp(r'^\d{2}/\d{2}$').hasMatch(line.text)) {
          expiryDate = line.text;
        }
      }
    }

    return {
      'cardNumber': cardNumber ?? '',
      'expiryDate': expiryDate ?? '',
    };
  }
}
