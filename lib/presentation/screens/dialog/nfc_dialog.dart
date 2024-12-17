import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ndef/ndef.dart' as ndef;
import '../../../theme/color.dart';

void showNfcCardScanDialog(BuildContext context) async {
  var availability = await FlutterNfcKit.nfcAvailability;
  if (availability != NFCAvailability.available) {
    _showNfcDisabledDialog(context);
  } else {
    _showNfcScanDialog(context);
    _startNfcScan(context);
  }
}

void _showNfcDisabledDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text("NFC o'chirilgan"),
        content: Text(
          "Iltimos, NFC funksiyasini yoqing va qayta urinib ko'ring.",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: darkGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Bekor qilish"),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              // Navigator.pop(context);
            },
            child: Text("Sozlamalar"),
          ),
        ],
      );
    },
  );
}

void _showNfcScanDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text("Kartani skanerlash"),
        content: Text(
          "Iltimos, kredit kartangizni telefon orqasiga yaqinlashtiring.",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: darkGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Bekor qilish"),
          ),
        ],
      );
    },
  );
}

void _startNfcScan(BuildContext context) async {
  String? cardNumber = await readCardNumber();
  String? expiryDate = await readExpiryDate();

  if (cardNumber != null && expiryDate != null) {
    print("Card Number: $cardNumber");
    print("Expiry Date: $expiryDate");
  }
  _showCardDetails(context, cardNumber!, expiryDate!, "cardData");
}
  Future<String?> readCardNumber() async {
    try {
      // Send SELECT command to the card to select the applet (assuming EMV card)
      String? selectResponse = await FlutterNfcKit.transceive("00A4040000");

      if (selectResponse != null && selectResponse.isNotEmpty) {
        // After selecting the applet, send the command to retrieve the card number (PAN)
        // Example APDU command to get the PAN
        String panResponse = await FlutterNfcKit.transceive("00B2010C00");

        // Extract the PAN (card number) from the response (this depends on the card)
        String cardNumber = panResponse.substring(4, 20); // Adjust based on actual response

        return cardNumber;
      }
    } catch (e) {
      print("Error reading card number: $e");
    }
    return null;
  }
  Future<String?> readExpiryDate() async {
    try {
      // Send APDU command to get the expiry date from the card (e.g., get from application data)
      String? selectResponse = await FlutterNfcKit.transceive("00A4040000");

      if (selectResponse != null && selectResponse.isNotEmpty) {
        // After selecting the applet, send command to retrieve expiry date (assuming it's available)
        String expiryResponse = await FlutterNfcKit.transceive("00B2010C01"); // Adjust as per card's structure

        // Parse the expiry date (usually in YYMM format)
        String expiryDate = expiryResponse.substring(4, 6) + '/' + expiryResponse.substring(6, 8); // YY/MM

        return expiryDate;
      }
    } catch (e) {
      print("Error reading expiry date: $e");
    }
    return null;
  }

void _showCardDetails(BuildContext context, String cardNumber,
    String expiryDate, String cardData) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Karta Ma'lumotlari",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: darkGray),
        ),
        content: Text(
          "Karta Raqami: $cardNumber\nAmal Qilish Muddati: $expiryDate. \n $cardData",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: darkGray),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context,
                  {'cardNumber': cardNumber, 'expiryDate': expiryDate});
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );

}
