import 'package:flutter/material.dart';

/// ألوان التطبيق الأساسية - مأخوذة من تصميم شاشة تسجيل الدخول
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE8552A);
  static const Color primaryDark = Color(0xFFD6431C);
  static const Color primaryLight = Color(0xFFF17A4E);
  static const Color grey = Color(0xFFCECECE);


  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textFieldFill = Color(0xFFF7F7F7);

  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color hintText = Color(0xFF9CA3AF);

  static const Color white = Color(0xFFFFFFFF);

  /// جراديانت الخلفية البرتقالي اللي بيتلاشى للأبيض تحت
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primaryLight, white],
    stops: [0.0, 0.48, 0.78],
  );

  /// جراديانت زرار تسجيل الدخول
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [primaryDark, primary],
  );
}
