
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:limon_pay/theme/color.dart';

import 'nfc_view_model.dart';


class NfcScreen extends StatefulWidget {
  const NfcScreen({super.key});

  @override
  State<NfcScreen> createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> {
  final NfcViewModel _viewModel = Get.put(NfcViewModel());

  @override
  void initState() {
    super.initState();
    _viewModel.startNFCReading();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      viewModel: _viewModel,
      onPageBuilder: (context, dynamic viewModel) => scaffoldBody(),
    );
  }

  Scaffold scaffoldBody() {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Obx(
                    () => Text(
                  _viewModel.message.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: darkGray),
                ),
              ),
              Text(
                "-------------------------------------",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: darkGray),
              ),
              Obx(
                    () => Text(
                  _viewModel.message1.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: darkGray),
                ),
              ),
              Text(
                "-------------------------------------",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: darkGray),
              ),
              Obx(
                    () => Text(
                  _viewModel.message2.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: darkGray),
                ),
              ),
              Text(
                "-------------------------------------",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: darkGray),
              ),
              Obx(
                    () => Text(
                  _viewModel.message3.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: darkGray),
                ),
              ),
              Text(
                "-------------------------------------",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: darkGray),
              ),
              Obx(
                    () => Text(
                  _viewModel.message4.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: darkGray),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
