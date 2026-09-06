import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr/core/di/service_locator.dart';
import 'package:mr/core/routing/routes.dart';
import 'package:mr/core/storage/token_storage.dart';
import 'package:mr/core/theme/app_colors.dart';
import 'package:mr/features/assistant/scan_qr_code/presentation/widgets/info_section_card.dart';
import 'package:mr/core/widgets/student_avatar.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..getProfile(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  static const double _headerHeight = 160;
  static const double _avatarRadius = 55;

  static String? _profileImageUrl(String? value) {
    final imageUrl = value?.trim();
    if (imageUrl == null || imageUrl.isEmpty) return null;

    final markdownMatch =
        RegExp(r'^\[[^\]]*\]\((https?://[^)]+)\)$').firstMatch(imageUrl);
    return markdownMatch?.group(1) ?? imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F9),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () => context.read<ProfileCubit>().getProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(
                        'إعادة المحاولة',
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            final student = (state as ProfileLoaded).profile;
            final profileImageUrl = _profileImageUrl(student.profileImage);

            return Stack(
              children: [
                Column(
                  children: [
                    // ---- الهيدر البرتقالي ----
                    Container(
                      height: _headerHeight.h,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                      ),
                    ),

                    // ---- الجسم ----
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 24.h,
                          left: 20.w,
                          right: 20.w,
                        ),
                        child: Column(
                          children: [
                            Text(
                              student.name,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            if (student.username.isNotEmpty)
                              Text(
                                '@${student.username}',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            SizedBox(height: 2.h),
                            Text(
                              student.grade,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),

                            SizedBox(height: 20.h),

                            InfoSectionCard(
                              title: 'المعلومات الشخصية',
                              rows: [
                                InfoRowData(
                                  label: 'معرف الطالب',
                                  value: student.id.toString(),
                                ),
                                if (student.studentCode.isNotEmpty)
                                  InfoRowData(
                                    label: 'كود الطالب',
                                    value: student.studentCode,
                                  ),
                                InfoRowData(
                                  label: 'الصف',
                                  value: student.grade,
                                ),
                                if (student.dob.isNotEmpty)
                                  InfoRowData(
                                    label: 'تاريخ الميلاد',
                                    value: student.dob,
                                  ),
                                InfoRowData(
                                    label: 'الاسم الكامل', value: student.name),
                                if (student.email.isNotEmpty)
                                  InfoRowData(
                                      label: 'البريد الإلكتروني',
                                      value: student.email),
                                InfoRowData(
                                    label: 'رقم هاتف للتواصل', value: student.phone),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            InfoSectionCard(
                              title: 'ولي الأمر',
                              rows: [
                                InfoRowData(
                                    label: 'اسم ولي الأمر',
                                    value: student.guardianName),
                                InfoRowData(
                                    label: 'رقم هاتف التواصل',
                                    value: student.guardianPhone),
                              ],
                            ),

                            SizedBox(height: 24.h),

                            SizedBox(
                              width: double.infinity,
                              height: 52.h,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await sl<TokenStorage>().clearToken();
                                  if (!context.mounted) return;
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    Routes.loginScreen,
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:const Color(0xFF3E8E4F),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                child: Text(
                                  'تسجيل الخروج',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ---- الصورة الشخصية معلقة بين الهيدر والجسم ----
                Positioned(
                  top: (_headerHeight - (_avatarRadius * 2) - 20).h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: StudentAvatar(
                      imageUrl: profileImageUrl,
                      radius: _avatarRadius.r,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
