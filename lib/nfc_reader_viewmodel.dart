import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import 'core/utils/log_service.dart';

class NfcReaderViewModel extends GetxController {
  RxString message = 'Ready to scan.'.obs;

  Future<void> startNFCReading() async {
    try {
      LogService.d('Checking NFC availability...');
      final bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        message.value = 'NFC is available. Ready to scan.';
        LogService.d('NFC is available. Starting session...');

        await NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            try {
              LogService.d('NFC tag discovered.');
              final isoDep = IsoDep.from(tag);

              if (isoDep == null) {
                throw Exception('IsoDep not supported on this tag.');
              }

              LogService.d('IsoDep tag detected. Establishing connection...');

              // Step 1: Select PPSE (2PAY.SYS.DDF01)
              LogService.d('Selecting PPSE...');
              final selectPPSE = await isoDep.transceive(data: Uint8List.fromList([
                0x00, 0xA4, 0x04, 0x00, 0x0E, 0x32, 0x50, 0x41, 0x59, 0x2E, 0x53, 0x59, 0x53, 0x2E, 0x44, 0x44, 0x46, 0x30, 0x31, 0x00
              ]));
              LogService.d('PPSE response: ${selectPPSE.toHexString()}');

              // Step 2: Parse applications and select one
              LogService.d('Selecting application...');
              final selectApp = await isoDep.transceive(data: Uint8List.fromList([
                0x00, 0xA4, 0x04, 0x00, 0x08, // Select File
                0xA0, 0x00, 0x00, 0x03, 0x33, 0x01, 0x01, 0x02, // AID from PPSE
                0x00 // Le
              ]));


              LogService.d('Application response: ${selectApp.toHexString()}');

              // Step 3: Get processing options
              LogService.d('Getting processing options...');
              final getProcessingOptions = await isoDep.transceive(data: Uint8List.fromList([
                0x80, 0xA8, 0x00, 0x00, 0x02, 0x83, 0x00, 0x00
              ]));
              LogService.d('Processing options response: ${getProcessingOptions.toHexString()}');

              // Step 4: Parse AFL and read records
              LogService.d('Parsing AFL...');
              final afl = getProcessingOptions.sublist(5); // Adjust as needed


              String cardNumber = '';
              String expiryDate = '';

              for (int i = 0; i < afl.length; i += 4) {
                final record = afl.sublist(i, i + 4);
                final sfi = record[0] >> 3;
                final firstRecord = record[1];
                final lastRecord = record[2];

                for (int recordNum = firstRecord; recordNum <= lastRecord; recordNum++) {
                  LogService.d('Reading record SFI $sfi, record $recordNum...');
                  final readRecord = await isoDep.transceive(data: Uint8List.fromList([
                    0x00, 0xB2, recordNum, (sfi << 3) | 0x04, 0x00
                  ]));
                  LogService.d('Record response: ${readRecord.toHexString()}');

                  if (readRecord.containsTag(0x5A)) {
                    cardNumber = readRecord.extractTag(0x5A).toHexString();
                    LogService.d('Card Number found: $cardNumber');
                  }

                  if (readRecord.containsTag(0x5F24)) {
                    expiryDate = readRecord.extractTag(0x5F24).toHexString();
                    LogService.d('Expiry Date found: $expiryDate');
                  }
                }
              }

              LogService.d('Final Card Number: $cardNumber');
              LogService.d('Final Expiry Date: $expiryDate');

              message.value =
              'Card Number: $cardNumber\nExpiry Date: $expiryDate';
              await NfcManager.instance.stopSession();
            } catch (e) {
              message.value = 'Error: $e';
              LogService.d('Error: $e');
              await NfcManager.instance.stopSession(errorMessage: e.toString());
            }
          },
        );
      } else {
        message.value = 'NFC is not available.';
        LogService.d('NFC is not available.');
      }
    } catch (e) {
      LogService.d("Error: $e");
      message.value = 'Error: $e';
    }
  }
}

extension HexUtils on Uint8List {
  String toHexString() => map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
}

extension NfcUtils on Uint8List {
  bool containsTag(int tag) {
    return indexOf(tag) != -1;
  }

  Uint8List extractTag(int tag) {
    final start = indexOf(tag);
    if (start == -1) return Uint8List(0);
    final length = this[start + 1];
    return sublist(start + 2, start + 2 + length);
  }
}
