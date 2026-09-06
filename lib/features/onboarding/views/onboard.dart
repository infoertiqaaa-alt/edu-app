import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr/core/helper/extentions.dart';
import 'package:mr/core/di/service_locator.dart';
import 'package:mr/core/routing/routes.dart';
import 'package:mr/core/storage/onboarding_storage.dart';
import 'package:mr/core/theme/app_colors.dart';
import 'package:mr/core/widgets/custom_button.dart';
import 'package:mr/features/onboarding/views/onboard1_view.dart';
import 'package:mr/features/onboarding/views/onboard2_view.dart';

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _RootState();
}

class _RootState extends State<Onboard> {
  late PageController controller;
  late List<Widget> screens;
  int currentScreen = 0;
  @override
  void initState() {
    screens = [Onboard1View(), Onboard2View()];
    controller = PageController(initialPage: currentScreen);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            physics: NeverScrollableScrollPhysics(),
            children: screens,
          ),

          Container(
            alignment: Alignment(0, .90),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: Row(
                    children: [
                      currentScreen > 0
                          ? IconButton(
                              onPressed: () {
                                if (currentScreen > 0) {
                                  setState(() {
                                    currentScreen--;
                                  });
                                  controller.jumpToPage(currentScreen);
                                }
                              },
                              icon: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Icon(
                                  size: 30,
                                  Icons.arrow_back,
                                  color: currentScreen == 1
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                Spacer(),
                 Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                     currentScreen == 1 ? 'اكتشف رحلة تعليمية جديدة وممتعة. نحن هنا لمساعدتك على التفوق وتحقيق أهدافك.':'استكشف عوالم جديدة من المعرفة معنا. نسهل عليك التعلم في أي وقت وأي كان. انضم إلينا اليوم!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Gap(26.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    screens.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: currentScreen == index ? 42 : 28,
                      decoration: BoxDecoration(
                        color: currentScreen == index
                            ? AppColors.primary
                            : AppColors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Gap(20.h),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 88.h,
                    left: 24.w,
                    right: 24.w,
                  ),
                  child: CustomButton(
                    text: currentScreen == 1 ? 'يلا نبدأ' : 'استمر',
                    onPressed: () async {
                      setState(() {
                        currentScreen++;
                      });
                      if (currentScreen < screens.length) {
                        controller.jumpToPage(currentScreen);
                        return;
                      }

                      await sl<OnboardingStorage>().markCompleted();
                      if (!context.mounted) return;
                      context.pushNamedAndRemoveUntil(
                        Routes.loginScreen,
                        predicate: (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
