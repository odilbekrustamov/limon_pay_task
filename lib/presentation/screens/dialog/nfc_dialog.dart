import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

import '../../../theme/color.dart';

void showNfcCardScanDialog(BuildContext context) async {
  var availability = await FlutterNfcKit.nfcAvailability;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          availability != NFCAvailability.available
              ? 'Telefoningizga kredit kartangizni yaqinlashtiring'
              : 'NFC ni yoqing',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: darkGray),
        ),
        content: Text(
          availability != NFCAvailability.available
              ? 'Kredit kartangizni telefoningizga yaqinlashtiring va NFC orqali o\'qishni kuting.'
              : 'Iltimos, telefoningizda NFC ni yoqing va yana bir bor urinib ko\'ring.',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: darkGray),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'OK',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: darkGray),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
