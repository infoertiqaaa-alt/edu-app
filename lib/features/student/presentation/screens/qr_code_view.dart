import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr/core/di/service_locator.dart';
import 'package:mr/core/helper/extentions.dart';
import 'package:mr/core/routing/routes.dart';
import 'package:mr/core/theme/app_colors.dart';
import 'package:mr/core/widgets/student_avatar.dart';
import 'package:mr/features/student/presentation/widgets/qr_code_widget.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..getProfile(),
      child: const _QrCodeBody(),
    );
  }
}

class _QrCodeBody extends StatelessWidget {
  const _QrCodeBody();

  static const double _headerHeight = 130;
  static const double _avatarRadius = 40;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F9),
        body: Stack(
          children: [
            Column(
              children: [
                //
                Container(
                  height: _headerHeight.h,
                  width: double.infinity,
                  color: AppColors.primary,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [  
                        Gap(10.h),
                        Expanded(
                          child: Text(
                            'رمز QR الخاص بي',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                       ],
                    ),
                  ),
                ),
                

                //body
                Expanded(
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      if (state is ProfileLoading || state is ProfileInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ProfileError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(fontSize: 15),
                                ),
                                Gap12(),
                                ElevatedButton(
                                  onPressed: () =>
                                      context.read<ProfileCubit>().getProfile(),
                                  child: Text('حاول تاني', style: GoogleFonts.cairo()),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final profile = (state as ProfileLoaded).profile;

                      return SingleChildScrollView(
                        padding: EdgeInsets.only(top: _avatarRadius.h + 16.h),
                        child: Column(
                          children: [
                            // ---- الاسم والصف ----
                            Text(
                              profile.name,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              profile.grade,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // ---- كارت الـ QR ----
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 24.w),
                              padding: EdgeInsets.symmetric(
                                  vertical: 24.h, horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1EEFC),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      'رمز QR الطالب',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF8B5CF6),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  QrCodeWidget(
                                    data: profile.qrCodeString,
                                    size: 200.w,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.w),
                              child: Text(
                                'اعرض هذا الرمز في المركز لتسجيل حضورك.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // ---- الصورة الشخصية معلقة بين الهيدر والجسم ----
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is! ProfileLoaded) return const SizedBox.shrink();
                final profile = state.profile;
                return Positioned(
                  top: _headerHeight.h - _avatarRadius,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: (){
                        context.pushNamed(Routes.profileView);
                      },
                      child: StudentAvatar(
                        imageUrl: profile.profileImage,
                        radius: _avatarRadius.r,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// عشان الكود يترجم من غير مشكلة، دي مجرد Gap صغيرة بديلة لو مش عايز تستورد gap هنا
class Gap12 extends StatelessWidget {
  const Gap12({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(height: 12.h);
}