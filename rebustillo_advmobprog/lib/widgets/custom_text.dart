import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.fontSize = 12,
    this.fontFamily = 'Poppins',
    this.fontWeight = FontWeight.normal,
    this.letterSpacing = 0,
    this.fontStyle = FontStyle.normal,
    this.overflow,
    this.maxLines,
    this.textAlign = TextAlign.left,
    this.color,
  });

  final String text;
  final double fontSize;
  final double? letterSpacing;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight fontWeight;
  final String fontFamily;
  final FontStyle fontStyle;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        color: color,
      ),
    );
  }
}