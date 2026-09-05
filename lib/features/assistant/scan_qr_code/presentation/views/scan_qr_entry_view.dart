import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher/core/di/service_locator.dart';
import 'package:teacher/core/routing/routes.dart';
import 'package:teacher/core/storage/token_storage.dart';
import 'package:teacher/core/theme/app_colors.dart';
import '../cubit/scan_qr_cubit.dart';
import 'scan_qr_camera_view.dart';

class ScanQrEntryView extends StatelessWidget {
  const ScanQrEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    // بنعمل الـ Cubit مرة واحدة هنا، وهنبعتها لباقي الشاشتين بنفس الـ instance
    // عن طريق BlocProvider.value عشان النتيجة تفضل موجودة لحد ما توصل للشاشة الأخيرة
    return BlocProvider(
      create: (_) => sl<ScanQrCubit>(),
      child: const _ScanQrEntryBody(),
    );
  }
}

class _ScanQrEntryBody extends StatelessWidget {
  const _ScanQrEntryBody();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await sl<TokenStorage>().clearToken();
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.loginScreen,
                          (route) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16.w),
                  ],
                ),
                SizedBox(height: 16.h),
                // خط صغير أعلى الشاشة (handle) زي التصميم
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Spacer(),

                // ---- الكارت الأبيض الرئيسي ----
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFBEAE3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 44.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'اضغط على زر المسح لتشغيل الكاميرا والتقاط الرمز\nالخاص بك فوراً',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ScanQrCubit>(),
                                  child: const ScanQrCameraView(),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E8E4F),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'مسح (Scan)',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
