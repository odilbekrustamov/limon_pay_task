import 'package:flutter/services.dart';

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String numbersOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbersOnly.length > 16) {
      numbersOnly = numbersOnly.substring(0, 16);
    }

    String formattedText = '';
    for (int i = 0; i < numbersOnly.length; i++) {
      formattedText += numbersOnly[i];
      if ((i + 1) % 4 == 0 && i != numbersOnly.length - 1) {
        formattedText += ' ';
      }
    }
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: formattedText.length,
      ),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String numbersOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbersOnly.length > 4) {
      numbersOnly = numbersOnly.substring(0, 4);
    }

    String formattedText = '';
    for (int i = 0; i < numbersOnly.length; i++) {
      if (i == 2) {
        formattedText += '/';
      }
      formattedText += numbersOnly[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
