import 'package:mr/core/utils/json_parsers.dart';

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
      id: JsonParsers.asIntOr(json['id'], 0),
      chapterName: JsonParsers.asString(json['chapter_name']),
      title: JsonParsers.asString(json['title']),
      durationMinutes: JsonParsers.asIntOr(json['duration_minutes'], 0),
      thumbnailUrl: JsonParsers.asString(json['thumbnail_url']),
    );
  }
}
