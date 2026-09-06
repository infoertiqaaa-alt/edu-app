class LessonNote {
  final int id;
  final int lessonId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LessonNote({
    required this.id,
    required this.lessonId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory LessonNote.fromMap(Map<String, Object?> map) {
    return LessonNote(
      id: map['id'] as int,
      lessonId: map['lesson_id'] as int,
      content: map['content'] as String,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}