
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teacher/core/theme/app_colors.dart';
import 'package:teacher/core/theme/font_weight_helper.dart';

class TextStyles{
  static TextStyle font24BlackBold  = TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeightHelper.bold,
      color: Colors.black
  );
  static TextStyle font32BlueBold  = TextStyle(
      fontSize: 32.sp,
      fontWeight: FontWeightHelper.bold,
      color: AppColors.primary
  );
  static TextStyle font24BlueBold  = TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeightHelper.bold,
      color: AppColors.primary
  );
  
  static TextStyle font14BlueSemiBold  = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeightHelper.semiBold,
      color: AppColors.primary
  );

}