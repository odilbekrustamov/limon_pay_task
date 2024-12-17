import 'package:flutter/material.dart';
import 'package:limon_pay/theme/color.dart';
import 'package:limon_pay/theme/shapes.dart';

class InputDecorationHelper {
  static InputDecoration getInputDecoration({
    required BuildContext context,
    required String labelText,
    required String hint,
    IconData? icon,
    bool isFocused = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: isFocused ? vividBlue : steelBlue),
      hintText: hint,
      hintStyle:
      Theme.of(context).textTheme.bodyMedium?.copyWith(color: lightGray),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(
        borderRadius: mediumShape,
        borderSide: BorderSide(color: isFocused ? vividBlue : paleBlueGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: mediumShape,
        borderSide: const BorderSide(color: vividBlue, width: 2.0),
      ),
      suffixIcon: icon != null
          ? SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          icon,
          color: isFocused ? vividBlue : paleBlueGray,
        ),
      )
          : null,
    );
  }
}
