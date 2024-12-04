import 'package:dorm_app/common/res/colors.dart';
import 'package:dorm_app/common/res/fonts.dart';
import 'package:flutter/material.dart';

class TextWidget {
  // ฟังก์ชันสำหรับสร้างหัวข้อหลัก
  static Widget buildHeader24(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Fonts.fontSize24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  // ฟังก์ชันสำหรับสร้างหัวข้อย่อย (หมายเลขข้อ)
  static Widget buildSection18(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: Fonts.fontSize18,
      fontWeight: FontWeight.bold),
    );
  }
  // ฟังก์ชันสำหรับสร้างหัวข้อย่อย (หมายเลขข้อ)
  static Widget buildSection16(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: Fonts.fontSize16,
      fontWeight: FontWeight.bold),
    );
  }

  // ฟังก์ชันสำหรับสร้างข้อความในแต่ละย่อย
  static Widget buildSubSection16(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: Fonts.fontSize16),
    );
  }

  // ฟังก์ชันสำหรับสร้างข้อความในแต่ละย่อย
  static Widget buildSubSection12(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: Fonts.fontSize12),
    );
  }

  static Widget buildSubSectionRed16(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: Fonts.fontSize16, color: ColorsApp.red),
    );
  }

  static Widget buildSubSectionRed12(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: Fonts.fontSize12, color: ColorsApp.red),
    );
  }

  static Widget buildSubSectionBold16(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: Fonts.fontSize16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  static Widget buildSubSectionBold14(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: Fonts.fontSize14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
