class LessonDetailModel {
  final int id;
  final String chapterName;
  final String title;
  final int durationMinutes;
  final String videoUrl;
  final String thumbnailUrl;
  final String aboutLesson;
  final List<String> whatYouWillLearn;
  final String notes;
  final String createdAt;
  final String updatedAt;
  final int? previousLessonId;
  final int? nextLessonId;

  const LessonDetailModel({
    required this.id,
    required this.chapterName,
    required this.title,
    required this.durationMinutes,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.aboutLesson,
    required this.whatYouWillLearn,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.previousLessonId,
    this.nextLessonId,
  });

  factory LessonDetailModel.fromJson(Map<String, dynamic> json) {
    return LessonDetailModel(
      id: json['id'] ?? 0,
      chapterName: json['chapter_name'] ?? '',
      title: json['title'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      aboutLesson: json['about_lesson'] ?? '',
      whatYouWillLearn: (json['what_you_will_learn'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      previousLessonId: json['previous_lesson_id'],
      nextLessonId: json['next_lesson_id'],
    );
  }
}
