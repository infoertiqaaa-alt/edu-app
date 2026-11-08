import 'package:flutter/material.dart';

/// Local font helpers.
///
/// Cairo and Tajawal are bundled with the app (SIL Open Font License), so text
/// renders correctly offline and the app no longer downloads fonts at runtime.
class AppFonts {
  AppFonts._();

  static const String cairoFamily = 'Cairo';
  static const String tajawalFamily = 'Tajawal';

  static TextStyle cairo({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: cairoFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontStyle: fontStyle,
      overflow: overflow,
    );
  }

  static TextStyle tajawal({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: tajawalFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontStyle: fontStyle,
      overflow: overflow,
    );
  }
}
