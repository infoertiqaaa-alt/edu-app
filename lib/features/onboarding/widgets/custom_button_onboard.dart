import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher/core/theme/app_colors.dart';

class CustomButtonOnboard extends StatelessWidget {
  const CustomButtonOnboard({
    super.key,
    required this.text,
    required this.ontap,
  });
  final String text;
  final Function()? ontap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: ontap,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.primary),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(horizontal: 121.w, vertical: 12.h),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}