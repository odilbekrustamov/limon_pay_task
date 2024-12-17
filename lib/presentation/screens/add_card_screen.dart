import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limon_pay/presentation/screens/formatter.dart';
import 'package:limon_pay/presentation/screens/scan_card/scan_card_screen.dart';
import 'package:limon_pay/presentation/widgets/input_decoration.dart';
import 'package:limon_pay/theme/color.dart';

import '../bloc/add_card/add_card_bloc.dart';
import '../widgets/icon_button_widget.dart';
import 'dialog/nfc_dialog.dart';
import 'scan_card/test_card.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final FocusNode cardNumberFocus = FocusNode();
  final FocusNode expiryDateFocus = FocusNode();
  final FocusNode cardholderNameFocus = FocusNode();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cardholderNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        title: Text(
          "Add new card",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: darkGray),
        ),
      ),
      body: BlocConsumer<AddCardBloc, AddCardState>(
        listener: (context, state) {
          setState(() {
            cardNumberController.text = state.cardNumber;
            expiryDateController.text = state.expiryDate;
            cardholderNameController.text = state.cardholderName;
          });
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Focus(
                  onFocusChange: (isFocused) => setState(() {}),
                  child: TextField(
                    controller: cardNumberController,
                    focusNode: cardNumberFocus,
                    decoration: InputDecorationHelper.getInputDecoration(
                      context: context,
                      labelText: 'Card Number',
                      hint: "0000 0000 0000 0000",
                      icon: Icons.credit_card,
                      isFocused: cardNumberFocus.hasFocus,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: darkGray),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      CardNumberInputFormatter(),
                    ],
                    onChanged: (value) {
                      context.read<AddCardBloc>().add(CardNumberChanged(value.trim()));
                      if (value.length == 19) {
                        FocusScope.of(context).requestFocus(expiryDateFocus);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Focus(
                  onFocusChange: (isFocused) => setState(() {}),
                  child: TextField(
                    controller: expiryDateController,
                    focusNode: expiryDateFocus,
                    decoration: InputDecorationHelper.getInputDecoration(
                      context: context,
                      labelText: 'Expiry Date',
                      hint: "MM/YY",
                      icon: Icons.calendar_month,
                      isFocused: expiryDateFocus.hasFocus,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: darkGray),
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [
                      ExpiryDateInputFormatter(),
                    ],
                    onChanged: (value) {
                      context.read<AddCardBloc>().add(ExpiryDateChanged(value));
                      if (value.length == 5) {
                        FocusScope.of(context).requestFocus(cardholderNameFocus);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Focus(
                  onFocusChange: (isFocused) => setState(() {}),
                  child: TextField(
                    controller: cardholderNameController,
                    focusNode: cardholderNameFocus,
                    decoration: InputDecorationHelper.getInputDecoration(
                      context: context,
                      labelText: "Cardholder's Name",
                      hint: "Enter cardholder’s full name",
                      isFocused: cardholderNameFocus.hasFocus,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: darkGray),
                    onChanged: (value) {
                      context.read<AddCardBloc>().add(CardholderNameChanged(value));
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: IconButtonWidget(
                        onPressed: () {
                          _openCameraScreen();
                        },
                        icon: Icons.camera_alt,
                        label: "Scan Card",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: IconButtonWidget(
                        onPressed: () {
                          showNfcCardScanDialog(context);
                        },
                        icon: Icons.nfc,
                        label: "NFC Card",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      )
    );
  }

  void _openCameraScreen() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanCardScreen(),
      ),
    ).then((result) {
      if (result != null) {
        String cardNumber = result['cardNumber'];
        String expiryDate = result['expiryDate'];
        context.read<AddCardBloc>().add(CardNumberChanged(cardNumber));
        context.read<AddCardBloc>().add(ExpiryDateChanged(expiryDate));

      }
    });

  }
}
