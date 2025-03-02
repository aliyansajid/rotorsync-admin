import 'package:flutter/material.dart';
import '../constants/colors.dart';

class Label extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const Label({
    super.key,
    required this.text,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w500,
    this.color = AppColors.slateGrey,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
