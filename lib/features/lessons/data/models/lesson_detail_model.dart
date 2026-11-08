import 'package:mr/core/utils/json_parsers.dart';

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
      id: JsonParsers.asIntOr(json['id'], 0),
      chapterName: JsonParsers.asString(json['chapter_name']),
      title: JsonParsers.asString(json['title']),
      durationMinutes: JsonParsers.asIntOr(json['duration_minutes'], 0),
      videoUrl: JsonParsers.asString(json['video_url']),
      thumbnailUrl: JsonParsers.asString(json['thumbnail_url']),
      aboutLesson: JsonParsers.asString(json['about_lesson']),
      whatYouWillLearn: JsonParsers.asStringList(json['what_you_will_learn']),
      notes: JsonParsers.asString(json['notes']),
      createdAt: JsonParsers.asString(json['created_at']),
      updatedAt: JsonParsers.asString(json['updated_at']),
      previousLessonId: JsonParsers.asInt(json['previous_lesson_id']),
      nextLessonId: JsonParsers.asInt(json['next_lesson_id']),
    );
  }
}
