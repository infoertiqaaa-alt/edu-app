import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../widgets/onboarding_background.dart';

class Onboard2View extends StatelessWidget {
  const Onboard2View({super.key});

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
                  Gap(50.h),
                  Image.asset(
                    'assets/onboarding2.png',
                    width: double.infinity,
                  ),
                  Gap(50.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}