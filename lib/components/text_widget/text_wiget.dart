import 'package:dorm_app/common/res/colors.dart';
import 'package:dorm_app/common/res/font.dart';
import 'package:dorm_app/common/res/size.dart';
import 'package:flutter/material.dart';

class TextWidget {
  static Widget buildHeader24(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Size.fontSize24,
        fontFamily: AppFonts.notoSansThai,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }
  static Widget buildHeader30(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Size.fontSize30,
        fontFamily: AppFonts.notoSansThai,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSection10(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Size.fontSize10,
          fontFamily: AppFonts.notoSansThai,
          fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSection14(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Size.fontSize14,
          fontFamily: AppFonts.notoSansThai,
          fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSection16(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Size.fontSize16,
          fontFamily: AppFonts.notoSansThai,
          fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSection18(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Size.fontSize18,
          fontFamily: AppFonts.notoSansThai,
          fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSection24(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Size.fontSize24,
          fontFamily: AppFonts.notoSansThai,
          fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSubSection12(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Size.fontSize12,
        fontFamily: AppFonts.notoSansThai,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSubSection14(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Size.fontSize14,
        fontFamily: AppFonts.notoSansThai,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSubSection16(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Size.fontSize16,
        fontFamily: AppFonts.notoSansThai,
      ),
      overflow: TextOverflow.visible,
    );
  }

  static Widget buildSubSection18(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Size.fontSize18,
        fontFamily: AppFonts.notoSansThai,
      ),
      overflow: TextOverflow.visible,
    );
  }

  static Widget buildSubSectionRed16(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Size.fontSize16,
        color: ColorsApp.red,
        fontFamily: AppFonts.notoSansThai,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSubSectionRed12(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Size.fontSize12,
        color: ColorsApp.red,
        fontFamily: AppFonts.notoSansThai,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSubSectionBold16(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: Size.fontSize16,
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.notoSansThai,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSubSectionBold20(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: Size.fontSize20,
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.notoSansThai,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSubSectionBold14(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: Size.fontSize14,
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.notoSansThai,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Widget buildSubSectionBold36(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: Size.fontSize36,
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.notoSansThai,
          color: ColorsApp.primary01),
      overflow: TextOverflow.ellipsis,
    );
  }


}
