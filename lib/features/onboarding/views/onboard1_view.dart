import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../widgets/onboarding_background.dart';

class Onboard1View extends StatelessWidget {
  const Onboard1View({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: OnboardingBackground(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: Column(
                children: [
                  Gap(100.h),
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 20.h),
                    child: Image.asset(
                      'assets/onboarding1.png',
                      width: double.infinity,
                    ),
                  ),
                  Gap(30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}