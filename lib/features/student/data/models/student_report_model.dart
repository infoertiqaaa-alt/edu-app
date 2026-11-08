import 'package:mr/core/utils/json_parsers.dart';

class StudentReportModel {
  final int id;
  final String name;
  final String studentCode;
  final String grade;
  final String groupName;
  final String? profileImage;

  const StudentReportModel({
    required this.id,
    required this.name,
    required this.studentCode,
    required this.grade,
    required this.groupName,
    required this.profileImage,
  });

  factory StudentReportModel.fromJson(Map<String, dynamic> json) {
    return StudentReportModel(
      id: JsonParsers.asIntOr(json['id'], 0),
      name: JsonParsers.asString(json['name']),
      studentCode: JsonParsers.asString(json['student_code']),
      grade: JsonParsers.asString(json['grade']),
      groupName: JsonParsers.asString(json['group_name']),
      profileImage: JsonParsers.asNullableString(json['profile_image']),
    );
  }
}
