import 'package:flutter/material.dart';
import 'typography.dart';
import 'shapes.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: 'Inter',
  textTheme: appTextTheme,
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(borderRadius: mediumShape),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: smallShape),
    ),
  ),
);
