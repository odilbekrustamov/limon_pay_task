import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'package:nfc_manager/platform_tags.dart';


class NfcViewModel extends GetxController {
  RxString message = ''.obs;
  RxString message1 = ''.obs;
  RxString message2 = ''.obs;
  RxString message3 = ''.obs;
  RxString message4 = ''.obs;

  // PPSE va PSE uchun AIDlar
  List<String> ppseAID = ['2PAY.SYS.DDF01']; // PPSE AID
  List<String> pseAID = ['1PAY.SYS.DDF01'];  // PSE AID

  // NFC o'qish jarayoni
  Future<void> startNFCReading() async {
    try {
      final bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        message.value = 'NFC is available.';

        await NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            try {
              final isoDep = IsoDep.from(tag);
              if (isoDep == null) {
                message.value = 'IsoDep not supported by this tag.';
                return;
              }

              message1.value = "${tag.data.toString()}";

              // PPSE yoki PSE ni tanlash
              bool success = await _selectAID(isoDep, true);  // true bo'lsa PPSE, false PSE
              if (success) {
                await _readCardData(isoDep);
              }

              await NfcManager.instance.stopSession();
            } catch (e) {
              message.value = 'Error: $e';
              await NfcManager.instance.stopSession(errorMessage: e.toString());
            }
          },
        );
      } else {
        message.value = 'NFC is not available.';
      }
    } catch (e) {
      message.value = e.toString();
    }
  }

  // AIDni yuborish va SELECT buyruqni bajarish
  Future<bool> _selectAID(IsoDep isoDep, bool isPPSE) async {
    // PPSE yoki PSE AID'ni tanlash
    List<String> aids = isPPSE ? ppseAID : pseAID;

    for (var aid in aids) {
      // AIDni yuborish formatini yaratish
      List<int> selectCommand = [
        0x00, 0xA4, 0x04, 0x00,  // SELECT Command Header
        aid.length ~/ 2,           // AID uzunligi
        ..._hexStringToBytes(aid), // AID ni yuborish
        0x00, // Le - Expected data length
      ];

      try {
        // Select buyruqni yuborish
        Uint8List response = await isoDep.transceive(data: Uint8List.fromList(selectCommand));

        // Muvaffaqiyatli javob tekshiruvi
        if (_isSuccessResponse(response)) {
          message.value = 'AID selected: $aid';
          message2.value = message2.value + '\nAID selected: $aid';
          return true;
        } else {
          message.value = 'Failed to select AID: $aid';
          message2.value = 'Failed to select AID: $aid';
          message4.value = 'Response: ${response.map((e) => e.toRadixString(16).padLeft(2, '0')).join()}';
        }
      } catch (e) {
        message.value = 'AID selection error: $e';
        message2.value = 'AID selection error: $e';
        message4.value = 'Error: $e';
      }
    }

    return false;
  }

  // Javob muvaffaqiyatli ekanligini tekshirish (90 00)
  bool _isSuccessResponse(Uint8List data) {
    return data.length >= 2 &&
        data[data.length - 2] == 0x90 &&
        data[data.length - 1] == 0x00;
  }

  // Hex stringni Uint8List ga o'zgartirish
  Uint8List _hexStringToBytes(String hex) {
    List<int> result = [];
    for (var i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(result);
  }

  // Track 2 ma'lumotlarini ajratib olish
  String _parseTrack2Data(Uint8List data) {
    String hexString = data.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    return hexString;
  }

  // Kartadan ma'lumot o'qish
  Future<void> _readCardData(IsoDep isoDep) async {
    Uint8List readCommand = Uint8List.fromList([
      0x00, 0xB2, 0x01, 0x0C, 0x00, // READ buyrug'i
    ]);

    try {
      Uint8List response = await isoDep.transceive(data: readCommand);

      if (_isSuccessResponse(response)) {
        String track2Data = _parseTrack2Data(response);
        message.value = 'Card Data: $track2Data';
        message3.value = 'Card Data: $response';
      } else {
        message.value = 'Failed to read card data.';
        message3.value = 'Failed to read card data.';
      }
    } catch (e) {
      message.value = 'Read error: $e';
      message3.value = 'Read error: $e';
    }
  }
}




class BaseView<T> extends StatelessWidget {
  final T viewModel;
  final Widget Function(BuildContext, T) onPageBuilder;

  const BaseView({
    Key? key,
    required this.viewModel,
    required this.onPageBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return onPageBuilder(context, viewModel);
  }
}
