class LessonModel {
  final int id;
  final String chapterName;
  final String title;
  final int durationMinutes;
  final String thumbnailUrl;

  const LessonModel({
    required this.id,
    required this.chapterName,
    required this.title,
    required this.durationMinutes,
    required this.thumbnailUrl,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? 0,
      chapterName: json['chapter_name'] ?? '',
      title: json['title'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      thumbnailUrl: json['thumbnail_url'] ?? '',
    );
  }
}
