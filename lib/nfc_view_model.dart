import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:typed_data';

import 'package:nfc_manager/platform_tags.dart';


class NfcViewModel extends GetxController {
  RxString message = ''.obs;
  RxString message1 = ''.obs;
  RxString message2 = ''.obs;
  RxString message3 = ''.obs;
  RxString message4 = ''.obs;

  // UzCard, Humo, Visa, UnionPay uchun AIDlar
  List<String> aids = [
    'A0000007710000', // Humo
    'A0000000031010', // Visa
    'A0000003330101', // UnionPay
    'A0000005272101', // UzCard
    'A0000000040000', // Mastercard
  ];

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
              for (var aid in aids) {
                message4.value = message4.value + aid;
                bool success = await _selectAID(isoDep, aid);
                if (success) {
                  await _readCardData(isoDep);
                  break;
                }
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

  Future<bool> _selectAID(IsoDep isoDep, String aid) async {
    Uint8List selectCommand = Uint8List.fromList([
      0x00, 0xA4, 0x04, 0x00,
      aid.length ~/ 2, // AID uzunligi
      ..._hexStringToBytes(aid),
      0x00, // Le
    ]);

    try {
      Uint8List response = await isoDep.transceive(data: selectCommand);

      if (_isSuccessResponse(response)) {
        message.value = 'AID selected: $aid';
        message2.value = message2.value +  '\nAID selected: $aid';
        return true;
      } else {
        message.value = 'Failed to select AID: $aid';
        message2.value = 'Failed to select AID: $aid';
      }
    } catch (e) {
      message.value = 'AID selection error: $e';
      message2.value = 'AID selection error: $e';
    }
    return false;
  }

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
}


// class NfcViewModel extends GetxController {
//   RxString message = ''.obs;
//   RxString message0 = ''.obs;
//   RxString message1 = ''.obs;
//   RxString message2 = ''.obs;
//   RxString message3 = ''.obs;
//
//   // UzCard, Humo, Visa, UnionPay uchun AIDlar
//   List<String> aids = [
//     'A0000007710000', // Humo
//     'A0000000031010', // Visa
//     'A0000005272101', // UzCard
//     'A0000003330101', // UnionPay
//   ];
//
//   Future<void> startNFCReading() async {
//     try {
//       final bool isAvailable = await NfcManager.instance.isAvailable();
//
//       if (isAvailable) {
//         message.value = 'NFC is available.';
//
//         await NfcManager.instance.startSession(
//           onDiscovered: (NfcTag tag) async {
//             try {
//               final isoDep = IsoDep.from(tag);
//               if (isoDep == null) {
//                 message.value = 'IsoDep not supported by this tag.';
//                 return;
//               }
//
//               message1.value = "${tag.data.toString()}";
//               for (var aid in aids) {
//                 bool success = await _selectAID(isoDep, aid);
//                 message0.value = "message ${aid}. ${success}";
//                 if (success) {
//                   await _readCardData(isoDep);
//                   break;
//                 }
//               }
//
//               await NfcManager.instance.stopSession();
//             } catch (e) {
//               message.value = 'Error: $e';
//               await NfcManager.instance.stopSession(errorMessage: e.toString());
//             }
//           },
//         );
//       } else {
//         message.value = 'NFC is not available.';
//       }
//     } catch (e) {
//       message.value = e.toString();
//     }
//   }
//
//   Future<bool> _selectAID(IsoDep isoDep, String aid) async {
//     Uint8List selectCommand = Uint8List.fromList([
//       0x00, 0xA4, 0x04, 0x00,
//       aid.length ~/ 2, // AID uzunligi
//       ..._hexStringToBytes(aid),
//       0x00, // Le
//     ]);
//
//     try {
//       Uint8List response = await isoDep.transceive(data: selectCommand);
//
//       if (_isSuccessResponse(response)) {
//         message.value = 'AID selected: $aid';
//         message2.value = 'AID selected: $aid';
//         return true;
//       } else {
//         message.value = 'Failed to select AID: $aid';
//         message2.value =  message2.value + '\nFailed to select AID: $aid';
//       }
//     } catch (e) {
//       message.value = 'AID selection error: $e';
//       message2.value = 'AID selection error: $e';
//     }
//     return false;
//   }
//
//   Future<void> _readCardData(IsoDep isoDep) async {
//     Uint8List readCommand = Uint8List.fromList([
//       0x00, 0xB2, 0x01, 0x0C, 0x00, // READ buyrug'i
//     ]);
//
//     try {
//       Uint8List response = await isoDep.transceive(data: readCommand);
//
//       if (_isSuccessResponse(response)) {
//         String track2Data = _parseTrack2Data(response);
//         message.value = 'Card Data: $track2Data';
//         message3.value = 'Card Data: $track2Data';
//       } else {
//         message.value = 'Failed to read card data.';
//         message3.value = 'Failed to read card data.';
//       }
//     } catch (e) {
//       message.value = 'Read error: $e';
//       message3.value = 'Read error: $e';
//     }
//   }
//
//
//   // Javob muvaffaqiyatli ekanligini tekshirish (90 00)
//   bool _isSuccessResponse(Uint8List data) {
//     return data.length >= 2 &&
//         data[data.length - 2] == 0x90 &&
//         data[data.length - 1] == 0x00;
//   }
//
//   // Hex stringni Uint8List ga o'zgartirish
//   Uint8List _hexStringToBytes(String hex) {
//     List<int> result = [];
//     for (var i = 0; i < hex.length; i += 2) {
//       result.add(int.parse(hex.substring(i, i + 2), radix: 16));
//     }
//     return Uint8List.fromList(result);
//   }
//
//   // Track 2 ma'lumotlarini ajratib olish
//   String _parseTrack2Data(Uint8List data) {
//     String hexString =
//         data.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
//     return hexString;
//   }
// }


// Future<void> _readCardData(IsoDep isoDep) async {
//   List<Uint8List> readCommands = [
//     Uint8List.fromList([0x00, 0xB2, 0x01, 0x0C, 0x00]), // UzCard
//     Uint8List.fromList([0x00, 0xB2, 0x01, 0x14, 0x00]), // Humo
//     Uint8List.fromList([0x00, 0xB2, 0x01, 0x1C, 0x00]), // Visa
//     Uint8List.fromList([0x00, 0xB2, 0x01, 0x24, 0x00]), // UnionPay
//   ];
//
//   for (var readCommand in readCommands) {
//     try {
//       Uint8List response = await isoDep.transceive(data: readCommand);
//
//       if (_isSuccessResponse(response)) {
//         String track2Data = _parseTrack2Data(response);
//         message.value = 'Card Data: $track2Data';
//         message3.value = 'Card Data: $track2Data';
//         return;
//       }
//     } catch (e) {
//       message.value = 'Read error: $e';
//       message3.value = 'Read error: $e';
//     }
//   }
//
//   message.value = 'Failed to read card data.';
//   message3.value = 'Failed to read card data.';
// }
/*
class NfcViewModel extends GetxController {
  RxString message = ''.obs;

  // Kartalar uchun AID'lar
  final List<Map<String, dynamic>> cardAIDs = [
    {'type': 'Visa', 'aid': [0xA0, 0x00, 0x00, 0x00, 0x03, 0x10, 0x10]},
    {'type': 'MasterCard', 'aid': [0xA0, 0x00, 0x00, 0x00, 0x04, 0x10, 0x10]},
    {'type': 'UzCard', 'aid': [0xA0, 0x00, 0x00, 0x04, 0x76, 0x44, 0x49]},
    {'type': 'Humo', 'aid': [0xA0, 0x00, 0x00, 0x04, 0x76, 0x44, 0x48]},
    {'type': 'UnionPay', 'aid': [0xA0, 0x00, 0x00, 0x03, 0x33, 0x01, 0x01]},
  ];

  Future<void> startNFCReading() async {
    try {
      final bool isAvailable = await NfcManager.instance.isAvailable();

      if (!isAvailable) {
        message.value = 'NFC is not available.';
        return;
      }

      message.value = 'NFC is available.';

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            if (kDebugMode) {
              print('Tag found: ${tag.data}');
            }
            message.value = 'Tag found: ${tag.data}';

            final IsoDep? isoDep = IsoDep.from(tag);
            if (isoDep != null) {
              for (var card in cardAIDs) {
                final aid = card['aid'] as List<int>;
                final type = card['type'];

                // AID tanlash komandi
                var aidCommand = [
                  0x00,
                  0xA4,
                  0x04,
                  0x00,
                  aid.length,
                  ...aid,
                  0x00
                ];
                var aidResponse = await isoDep.transceive(
                    data: Uint8List.fromList(aidCommand));
                if (kDebugMode) {
                  print('$type AID Response: $aidResponse');
                }
                if (aidResponse.isEmpty) continue;

                // GPO (Get Processing Options) komandi
                var gpoCommand = [
                  0x80,
                  0xA8,
                  0x00,
                  0x00,
                  0x02,
                  0x83,
                  0x00,
                  0x00
                ];
                var gpoResponse = await isoDep.transceive(
                    data: Uint8List.fromList(gpoCommand));
                if (kDebugMode) {
                  print('GPO Response: $gpoResponse');
                }
                if (gpoResponse.isEmpty) continue;

                // Ma'lumotlarni o'qish uchun RECORD komandasi
                var readRecordCommand = [0x00, 0xB2, 0x01, 0x0C, 0x00];
                var readRecordResponse = await isoDep.transceive(
                    data: Uint8List.fromList(readRecordCommand));
                if (kDebugMode) {
                  print('Read Record Response: $readRecordResponse');
                }
                if (readRecordResponse.isEmpty) continue;

                // Kart ma'lumotlarini ajratish
                final cardDetails = parseCardDetails(readRecordResponse, type);
                message.value = cardDetails;
                await NfcManager.instance.stopSession();
                return;
              }

              message.value = 'No supported card found.';
              await NfcManager.instance.stopSession();
            } else {
              message.value = 'IsoDep not supported on this tag.';
            }
          } catch (e) {
            message.value = 'Error: $e';
            await NfcManager.instance.stopSession(errorMessage: e.toString());
          }
        },
      );
    } catch (e) {
      message.value = e.toString();
    }
  }

  String parseCardDetails(Uint8List response, String cardType) {
    String hexString = response
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();

    if (hexString.length < 20) {
      return 'Error: Insufficient data length. Response length is ${hexString.length}';
    }

    try {
      final cardNumber = hexString.substring(0, 16);
      final expiryDate = hexString.substring(16, 20);
      return 'Card Type: $cardType\nCard Number: $cardNumber\nExpiry Date: $expiryDate';
    } catch (e) {
      return 'Error parsing card details: $e';
    }
  }
}
*/

// class NfcViewModel extends GetxController {
//   RxString message = ''.obs;
//
//   Future<void> startNFCReading() async {
//     try {
//       final bool isAvailable = await NfcManager.instance.isAvailable();
//
//       if (isAvailable) {
//         message.value = 'NFC is available.';
//
//         await NfcManager.instance.startSession(
//           onDiscovered: (NfcTag tag) async {
//             try {
//               if (kDebugMode) {
//                 print('Tag found: ${tag.data}');
//               }
//               message.value = 'Tag found: ${tag.data}';
//
//               final IsoDep? isoDep = IsoDep.from(tag);
//               if (isoDep != null) {
//                 // PPSE (Proximity Payment System Environment) seçimi
//                 var ppseCommand = [
//                   0x00,
//                   0xA4,
//                   0x04,
//                   0x00,
//                   0x0E,
//                   0x32,
//                   0x50,
//                   0x41,
//                   0x59,
//                   0x2E,
//                   0x53,
//                   0x59,
//                   0x53,
//                   0x2E,
//                   0x44,
//                   0x44,
//                   0x46,
//                   0x30,
//                   0x31,
//                   0x00
//                 ];
//                 var ppseResponse = await isoDep.transceive(
//                     data: Uint8List.fromList(ppseCommand));
//                 if (kDebugMode) {
//                   print('PPSE Response: $ppseResponse');
//                 }
//                 if (ppseResponse.isEmpty) {
//                   message.value = 'PPSE Response is empty.';
//                   await NfcManager.instance.stopSession();
//                   return;
//                 }
//
//                 // PPSE yanıtını işle ve AID'yi al
//                 var aid = extractAidFromPpseResponse(ppseResponse);
//                 if (aid == null) {
//                   message.value = 'Failed to extract AID from PPSE response.';
//                   await NfcManager.instance.stopSession();
//                   return;
//                 }
//
//                 // AID seçim komutu
//                 var aidCommand = [
//                   0x00,
//                   0xA4,
//                   0x04,
//                   0x00,
//                   aid.length,
//                   ...aid,
//                   0x00
//                 ];
//                 var aidResponse = await isoDep.transceive(
//                     data: Uint8List.fromList(aidCommand));
//                 if (kDebugMode) {
//                   print('AID Response: $aidResponse');
//                 }
//                 if (aidResponse.isEmpty) {
//                   message.value = 'AID Response is empty.';
//                   await NfcManager.instance.stopSession();
//                   return;
//                 }
//
//                 // GET PROCESSING OPTIONS komutu
//                 var gpoCommand = [
//                   0x80,
//                   0xA8,
//                   0x00,
//                   0x00,
//                   0x02,
//                   0x83,
//                   0x00,
//                   0x00
//                 ];
//                 var gpoResponse = await isoDep.transceive(
//                     data: Uint8List.fromList(gpoCommand));
//                 if (kDebugMode) {
//                   print('GPO Response: $gpoResponse');
//                 }
//                 if (gpoResponse.isEmpty) {
//                   message.value = 'GPO Response is empty.';
//                   await NfcManager.instance.stopSession();
//                   return;
//                 }
//
//                 // RECORD okuma komutu
//                 var readRecordCommand = [0x00, 0xB2, 0x01, 0x0C, 0x00];
//                 var readRecordResponse = await isoDep.transceive(
//                     data: Uint8List.fromList(readRecordCommand));
//                 if (kDebugMode) {
//                   print('Read Record Response: $readRecordResponse');
//                 }
//                 if (readRecordResponse.isEmpty) {
//                   message.value = 'Read Record Response is empty.';
//                   await NfcManager.instance.stopSession();
//                   return;
//                 }
//
//                 // Kart bilgilerini ayıkla
//                 final cardDetails = parseCardDetails(readRecordResponse);
//                 message.value = cardDetails;
//
//                 await NfcManager.instance.stopSession();
//               } else {
//                 message.value = 'IsoDep not supported on this tag.';
//               }
//             } catch (e) {
//               message.value = 'Error: $e';
//               await NfcManager.instance.stopSession(errorMessage: e.toString());
//             }
//           },
//         );
//       } else {
//         message.value = 'NFC is not available.';
//       }
//     } catch (e) {
//       message.value = e.toString();
//     }
//   }
//
//   List<int>? extractAidFromPpseResponse(Uint8List response) {
//     try {
//       int index = 0;
//       while (index < response.length) {
//         int tag = response[index++];
//         int length = response[index++];
//         if (tag == 0x4F) {
//           // AID tag
//           return response.sublist(index, index + length);
//         }
//         index += length;
//       }
//       return null;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error extracting AID: $e');
//       }
//       return null;
//     }
//   }
//
//   String parseCardDetails(Uint8List response) {
//     String hexString = response
//         .map((e) => e.toRadixString(16).padLeft(2, '0'))
//         .join()
//         .toUpperCase();
//
// // Yanıtın uzunluğunu kontrol edin
//     if (hexString.length < 20) {
//       return 'Error: Insufficient data length. Response length is ${hexString.length}';
//     }
//
//     try {
//       // Example extraction logic (adjust based on actual card data structure)
//       final cardNumber =
//       hexString.substring(0, 16); // Example: first 16 characters
//       final expiryDate =
//       hexString.substring(16, 20); // Example: next 4 characters
//       return 'Card Number: $cardNumber, Expiry Date: $expiryDate';
//     } catch (e) {
//       return 'Error parsing card details: $e';
//     }
//   }
// }

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
