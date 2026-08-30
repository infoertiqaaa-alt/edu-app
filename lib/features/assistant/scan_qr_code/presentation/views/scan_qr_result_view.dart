import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher/core/routing/routes.dart';
import 'package:teacher/core/theme/app_colors.dart';
import 'package:teacher/core/widgets/app_error_dialog.dart';
import 'package:teacher/core/widgets/student_avatar.dart';
import '../cubit/scan_qr_cubit.dart';
import '../cubit/scan_qr_state.dart';
import '../widgets/info_section_card.dart';

class ScanQrResultView extends StatefulWidget {
  const ScanQrResultView({super.key});

  @override
  State<ScanQrResultView> createState() => _ScanQrResultViewState();
}

class _ScanQrResultViewState extends State<ScanQrResultView> {
  bool _isRegistering = false;

  static const double _headerHeight = 280;
  static const double _avatarRadius = 80;

  static String? _profileImageUrl(String? value) {
    final imageUrl = value?.trim();
    if (imageUrl == null || imageUrl.isEmpty) return null;

    final markdownMatch =
        RegExp(r'^\[[^\]]*\]\((https?://[^)]+)\)$').firstMatch(imageUrl);
    return markdownMatch?.group(1) ?? imageUrl;
  }

  Future<void> _registerAttendance(int studentId) async {
    if (_isRegistering) return;

    setState(() => _isRegistering = true);
    final failure =
        await context.read<ScanQrCubit>().registerAttendance(studentId);

    if (!mounted) return;
    setState(() => _isRegistering = false);

    if (failure != null) {
      await AppErrorDialog.show(context, message: failure.message);
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تسجيل الحضور بنجاح',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.scanQrEntry,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F9),
        body: BlocBuilder<ScanQrCubit, ScanQrState>(
          builder: (context, state) {
            if (state is! ScanQrSuccess) {
              // مفروض ميوصلش هنا غير لما يبقى فيه بيانات، بس احتياطًا
              return const Center(child: CircularProgressIndicator());
            }

            final student = state.student;
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
                            if (student.studentNumber?.isNotEmpty ?? false)
                              Text(
                                'رقم الطالب: #${student.studentNumber}',
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
                                if (student.studentNumber?.isNotEmpty ?? false)
                                  InfoRowData(
                                    label: 'كود الطالب',
                                    value: student.studentNumber!,
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
                                onPressed: () {
                                   _registerAttendance(student.id);
                                  // TODO: نادِ هنا endpoint تسجيل الحضور لما يبقى جاهز
                                  // مثال: context.read<AttendanceCubit>().checkIn(student.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                child: Text(
                                  'تسجيل الحضور',
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
