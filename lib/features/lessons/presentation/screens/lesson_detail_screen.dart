import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher/core/di/service_locator.dart';
import 'package:teacher/core/theme/app_colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/models/lesson_detail_model.dart';
import '../cubit/lesson_detail_cubit.dart';
import '../cubit/lesson_detail_state.dart';

class LessonDetailScreen extends StatelessWidget {
  final int lessonId;
  const LessonDetailScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LessonDetailCubit>()..getLessonDetail(lessonId),
      child: const _LessonDetailBody(),
    );
  }
}

class _LessonDetailBody extends StatelessWidget {
  const _LessonDetailBody();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: BlocBuilder<LessonDetailCubit, LessonDetailState>(
          builder: (context, state) {
            if (state is LessonDetailLoading || state is LessonDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LessonDetailError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, style: GoogleFonts.cairo(fontSize: 15)),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('رجوع', style: GoogleFonts.cairo()),
                    ),
                  ],
                ),
              );
            }

            final lesson = (state as LessonDetailLoaded).lesson;

            return Column(
              children: [
                _CustomAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VideoPlayerWidget(lesson: lesson),
                        LessonHeaderInfo(lesson: lesson),
                        LessonNavigationRow(lesson: lesson),
                        LessonTabSection(lesson: lesson),
                      ],
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

class _CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 18.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'الدروس',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'مشاهدة الدرس',
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              SizedBox(width: 80.w),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final LessonDetailModel lesson;
  const VideoPlayerWidget({super.key, required this.lesson});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  static const String _staticVideoId = 'AEHJqatke6E';
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _staticVideoId,
      autoPlay: false,
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
    );
  }
}

class LessonHeaderInfo extends StatelessWidget {
  final LessonDetailModel lesson;
  const LessonHeaderInfo({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${lesson.durationMinutes} دقيقة',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class LessonNavigationRow extends StatelessWidget {
  final LessonDetailModel lesson;
  const LessonNavigationRow({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: lesson.previousLessonId != null
                ? _NavButton(
                    label: 'الدرس السابق',
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () {},
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: lesson.nextLessonId != null
                ? _NavButton(
                    label: 'الدرس التالي',
                    icon: Icons.arrow_forward_ios_rounded,
                    isLeading: true,
                    onTap: () {},
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLeading;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    this.isLeading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLeading) ...[
              Icon(icon, color: AppColors.primary, size: 14.w),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            if (isLeading) ...[
              SizedBox(width: 4.w),
              Icon(icon, color: AppColors.primary, size: 14.w),
            ],
          ],
        ),
      ),
    );
  }
}

class LessonTabSection extends StatelessWidget {
  final LessonDetailModel lesson;
  const LessonTabSection({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 14.h),
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'نظرة عامة'),
                Tab(text: 'ملاحظات'),
              ],
            ),
          ),
          SizedBox(
            height: 300.h,
            child: TabBarView(
              children: [
                OverviewTabContent(lesson: lesson),
                NotesTabContent(lesson: lesson),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OverviewTabContent extends StatelessWidget {
  final LessonDetailModel lesson;
  const OverviewTabContent({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عن هذا الدرس',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            lesson.aboutLesson,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.7,
            ),
          ),
          if (lesson.whatYouWillLearn.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Text(
              'ما ستتعلمه',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            ...lesson.whatYouWillLearn.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NotesTabContent extends StatelessWidget {
  final LessonDetailModel lesson;
  const NotesTabContent({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    if (lesson.notes.isEmpty) {
      return Center(
        child: Text(
          'لا توجد ملاحظات',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          lesson.notes,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.7,
          ),
        ),
      ),
    );
  }
}
