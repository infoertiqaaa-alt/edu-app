import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher/core/di/service_locator.dart';
import 'package:teacher/core/helper/extentions.dart';
import 'package:teacher/core/routing/routes.dart';
import 'package:teacher/core/theme/app_colors.dart';
import '../../data/models/lesson_model.dart';
import '../cubit/lessons_cubit.dart';
import '../cubit/lessons_state.dart';

class LessonsListScreen extends StatelessWidget {
  const LessonsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LessonsCubit>()..getLessons(),
      child: const _LessonsListBody(),
    );
  }
}

class _LessonsListBody extends StatelessWidget {
  const _LessonsListBody();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            const _HeaderWidget(),
            Expanded(
              child: BlocBuilder<LessonsCubit, LessonsState>(
                builder: (context, state) {
                  if (state is LessonsLoading || state is LessonsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is LessonsError) {
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
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<LessonsCubit>().getLessons(),
                              child:
                                  Text('حاول تاني', style: GoogleFonts.cairo()),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final lessons = (state as LessonsLoaded).lessons;

                  if (lessons.isEmpty) {
                    return Center(
                      child: Text(
                        'لا يوجد دروس حالياً',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<LessonsCubit>().getLessons(),
                    child: _LessonsContent(lessons: lessons),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        // borderRadius: BorderRadius.only(
        //   bottomLeft: Radius.circular(24.r),
        //   bottomRight: Radius.circular(24.r),
        // ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  Text(
                    'الدروس',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 22.w,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'تابع تقدمك في المنهج الأكاديمي',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonsContent extends StatelessWidget {
  final List<LessonModel> lessons;
  const _LessonsContent({required this.lessons});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'الدروس',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              itemCount: lessons.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return LessonCardWidget(
                  lesson: lesson,
                  onTap: () {
                    context.pushNamed(
                      Routes.lessonDetail,
                      arguments: lesson.id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LessonCardWidget extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onTap;

  const LessonCardWidget({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        lesson.chapterName,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'مدة الفيديو: ${lesson.durationMinutes} دقيقة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    lesson.thumbnailUrl,
                    width: 110.w,
                    height: 85.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 110.w,
                      height: 85.h,
                      color: AppColors.grey.withValues(alpha: 0.3),
                      child: const Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22.w,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
