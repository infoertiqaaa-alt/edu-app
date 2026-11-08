import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr/core/theme/app_fonts.dart';
import 'package:mr/core/di/service_locator.dart';
import 'package:mr/core/extensions/context_extensions.dart';
import 'package:mr/core/routing/routes.dart';
import 'package:mr/core/theme/app_colors.dart';
import 'package:mr/features/lessons/domain/logic/youtube_url_parser.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/models/lesson_detail_model.dart';
import '../../data/models/lesson_note_model.dart';
import '../cubit/lesson_detail_cubit.dart';
import '../cubit/lesson_detail_state.dart';
import '../cubit/lesson_notes_cubit.dart';
import '../cubit/lesson_notes_state.dart';
import '../widgets/add_note_dialog.dart';
import '../widgets/lesson_video_controls.dart';

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

class _LessonDetailBody extends StatefulWidget {
  const _LessonDetailBody();

  @override
  State<_LessonDetailBody> createState() => _LessonDetailBodyState();
}

class _LessonDetailBodyState extends State<_LessonDetailBody>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: BlocBuilder<LessonDetailCubit, LessonDetailState>(
          builder: (context, state) {
            if (state is LessonDetailLoading || state is LessonDetailInitial) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is LessonDetailError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, style: AppFonts.cairo(fontSize: 15)),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: Text('رجوع', style: AppFonts.cairo()),
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
                onTap: () => context.pushReplacement(Routes.root1),
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
                      style: AppFonts.cairo(
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
                style: AppFonts.cairo(
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
  String? _videoId;
  YoutubePlayerController? _controller;
  bool _showThumbnail = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubeUrlParser.extractVideoId(widget.lesson.videoUrl);
    if (_videoId == null) return;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: _videoId!,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        strictRelatedVideos: true,
        loop: true,
      ),
    );
    _controller!.setFullScreenListener(_onFullScreenChanged);
  }

  @override
  void dispose() {
    _controller?.setFullScreenListener((_) {});
    _controller?.close();
    super.dispose();
  }

  void _onFullScreenChanged(bool isFullScreen) {
    if (!mounted) return;
    setState(() => _isFullScreen = isFullScreen);
    if (isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _startPlayback() {
    setState(() => _showThumbnail = false);
    _controller?.playVideo();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final videoId = _videoId;

    // Never substitute a hardcoded demo video for a missing/invalid lesson URL.
    if (controller == null || videoId == null) {
      return const _VideoUnavailablePlaceholder();
    }

    return PopScope(
      canPop: !_isFullScreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isFullScreen) {
          controller.exitFullScreen(lock: false);
        }
      },
      child: YoutubePlayer(
        controller: controller,
        builder: (context, player, controller) {
          if (controller.value.hasError) {
            return _VideoPlaybackError(
              onRetry: () => controller.loadVideoById(videoId: videoId),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              player,
              LessonVideoControls(controller: controller),
              if (_showThumbnail && !_isFullScreen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _startPlayback,
                    child: widget.lesson.thumbnailUrl.isNotEmpty
                        ? Image.network(
                            widget.lesson.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const _ThumbnailPlaceholder(),
                          )
                        : const _ThumbnailPlaceholder(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _VideoUnavailablePlaceholder extends StatelessWidget {
  const _VideoUnavailablePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam_off_rounded, color: Colors.white70, size: 48.w),
          SizedBox(height: 12.h),
          Text(
            'الفيديو غير متاح لهذا الدرس حاليًا.',
            textAlign: TextAlign.center,
            style: AppFonts.cairo(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _VideoPlaybackError extends StatelessWidget {
  final VoidCallback onRetry;

  const _VideoPlaybackError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.white70, size: 44.w),
          SizedBox(height: 10.h),
          Text(
            'تعذر تشغيل الفيديو.',
            textAlign: TextAlign.center,
            style: AppFonts.cairo(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            child: Text('إعادة المحاولة', style: AppFonts.cairo()),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Icon(
        Icons.play_circle_fill_rounded,
        color: AppColors.primary,
        size: 64.w,
      ),
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
            style: AppFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${lesson.durationMinutes} دقيقة',
            style: AppFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
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
                    onTap: () {
                      context.push(
                        Routes.lessonDetail,
                        arguments: lesson.previousLessonId,
                      );
                    },
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
                    onTap: () {
                      context.push(
                        Routes.lessonDetail,
                        arguments: lesson.nextLessonId,
                      );
                    },
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
              style: AppFonts.cairo(
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
              labelStyle: AppFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: AppFonts.cairo(
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
            style: AppFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            lesson.aboutLesson,
            style: AppFonts.cairo(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.7,
            ),
          ),
          if (lesson.whatYouWillLearn.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Text(
              'ما ستتعلمه',
              style: AppFonts.cairo(
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
                        style: AppFonts.cairo(
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
    return BlocProvider(
      create: (_) => sl<LessonNotesCubit>()..loadNotes(lesson.id),
      child: _NotesTabBody(lesson: lesson),
    );
  }
}

class _NotesTabBody extends StatelessWidget {
  final LessonDetailModel lesson;
  const _NotesTabBody({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonNotesCubit, LessonNotesState>(
      builder: (context, state) {
        if (state is LessonNotesLoading || state is LessonNotesInitial) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is LessonNotesError) {
          return Center(
            child: Text(
              state.message,
              style: AppFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        final notes = (state as LessonNotesLoaded).notes;

        return Column(
          children: [
            Expanded(
              child: notes.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد ملاحظات',
                        style: AppFonts.cairo(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: notes.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _NoteCard(
                          index: index,
                          note: note,
                          onEdit: () => _showNoteDialog(
                            context,
                            lessonId: lesson.id,
                            note: note,
                          ),
                          onDelete: () => _deleteNote(context, note),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showNoteDialog(context, lessonId: lesson.id),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text('إضافة ملاحظة', style: AppFonts.cairo()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(BuildContext context, LessonNote note) {
    final cubit = context.read<LessonNotesCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('حذف الملاحظة', style: AppFonts.cairo()),
        content: Text(
          'هل أنت متأكد من حذف هذه الملاحظة؟',
          style: AppFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text('إلغاء', style: AppFonts.cairo()),
          ),
          TextButton(
            onPressed: () {
              dialogContext.pop();
              cubit.deleteNote(note);
            },
            child: Text('حذف', style: AppFonts.cairo(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(
    BuildContext context, {
    required int lessonId,
    LessonNote? note,
  }) {
    final cubit = context.read<LessonNotesCubit>();
    final controller = TextEditingController(text: note?.content ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) => AddNoteDialog(
        controller: controller,
        isEditing: note != null,
        onSaved: (content) {
          if (note == null) {
            cubit.addNote(lessonId, content);
          } else {
            cubit.updateNote(note, content);
          }
        },
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final int index;
  final LessonNote note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.index,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: index.isEven ? const Color(0xFFFFF8E1) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  tooltip: 'تعديل',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Colors.red,
                  ),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ),
          Text(
            note.content,
            style: AppFonts.cairo(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
