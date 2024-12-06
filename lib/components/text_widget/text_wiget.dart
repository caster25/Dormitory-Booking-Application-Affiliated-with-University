import 'package:dorm_app/common/res/font.dart';
import 'package:flutter/material.dart';

class TextWidget {
  static Widget buildText({
    required String text,
    double? fontSize,
    Color color = Colors.black ,
    bool isBold = false,
    TextAlign textAlign = TextAlign.start,
    bool wrapText = true,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 14,
        fontFamily: AppFonts.notoSansThai,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
      ),
      textAlign: textAlign,
      overflow: wrapText ? TextOverflow.visible : TextOverflow.ellipsis,
      maxLines: wrapText ? null : 1,
      softWrap: wrapText,
    );
  }
}
