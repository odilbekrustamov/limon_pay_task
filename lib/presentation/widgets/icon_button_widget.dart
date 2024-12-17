
import 'package:flutter/material.dart';

import '../../theme/color.dart';
import '../../theme/shapes.dart';

class IconButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color labelColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final double borderWidth;

  const IconButtonWidget({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.iconColor = vividBlue,
    this.labelColor = vividBlue,
    this.borderColor = vividBlue,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor),
      label: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: labelColor,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor, width: borderWidth),
        shape: RoundedRectangleBorder(borderRadius: mediumShape),
        padding: padding,
        overlayColor: Colors.grey.withOpacity(0.2),
      ),
    );
  }
}
