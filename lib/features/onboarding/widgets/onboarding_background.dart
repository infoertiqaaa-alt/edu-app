import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingBackground extends StatelessWidget {
  final Widget? child;
  final Color backgroundColor;
  final Color iconColor;

  const OnboardingBackground({
    super.key,
    this.child,
    this.backgroundColor = Colors.white,
    this.iconColor = const Color(0xFFD4D4D4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: Stack(
        children: [
          Positioned(
            left: 15.w,
            top: 55.h,
            child: SizedBox(
              width: 80.w,
              height: 80.h,
              child: Image.asset('assets/item3.png', fit: BoxFit.contain),
            ),
          ),
          Positioned(
            left: 285.w,
            top: 52.h,
            child: SizedBox(
              width: 95.w,
              height: 95.h,
              child: Image.asset('assets/token_atom.png', fit: BoxFit.contain),
            ),
          ),
          Positioned(
            left: 2.w,
            top: 460.h,
            child: SizedBox(
              width: 95.w,
              height: 95.h,
              child: Image.asset('assets/item2.png', fit: BoxFit.contain),
            ),
          ),
          Positioned(
            left: 273.w,
            top: 452.h,
            child: SizedBox(
              width: 78.w,
              height: 78.h,
              child: Image.asset('assets/token_atom.png', fit: BoxFit.contain),
            ),
          ),
          Positioned(
            left: 293.w,
            top: 578.h,
            child: SizedBox(
              width: 82.w,
              height: 82.h,
              child: Image.asset('assets/token_atom.png', fit: BoxFit.contain),
            ),
          ),
          if (child != null) Positioned.fill(child: child!),
        ],
      ),
    );
  }
}
