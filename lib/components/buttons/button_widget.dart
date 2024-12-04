import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String label; // ข้อความบนปุ่ม
  final VoidCallback onPressed; // ฟังก์ชันเมื่อกดปุ่ม
  final Color backgroundColor; // สีของปุ่ม
  final double fontSize; // ขนาดตัวอักษร
  final Color fontcolor;

  const ButtonWidget({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor ,
    this.fontSize = 20, 
    required this.fontcolor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: fontSize, color: fontcolor),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double borderRadius;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF9B59B6), // สีพื้นหลังเริ่มต้น
    this.borderRadius = 10.0,
    this.textStyle = const TextStyle(fontSize: 18, color: Colors.white), 
    this.padding = const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
      child: Text(label, style: textStyle),
    );
  }
}


