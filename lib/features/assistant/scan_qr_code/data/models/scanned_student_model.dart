import 'package:mr/core/utils/json_parsers.dart';

/// Student data returned after scanning a QR code.
class ScannedStudentModel {
  final int id;
  final String name;
  final String? studentNumber;
  final String grade;
  final String phone;
  final String? profileImage;
  final String dob;
  final String guardianName;
  final String guardianPhone;

  const ScannedStudentModel({
    required this.id,
    required this.name,
    this.studentNumber,
    required this.grade,
    required this.phone,
    this.profileImage,
    required this.dob,
    required this.guardianName,
    required this.guardianPhone,
  });

  factory ScannedStudentModel.fromJson(Map<String, dynamic> json) {
    final number =
        json['student_number'] ?? json['student_code'] ?? json['studentNumber'];
    final profile = json['profile_image'] ?? json['profileImage'];

    return ScannedStudentModel(
      id: JsonParsers.asIntOr(json['student_id'] ?? json['id'], 0),
      name: JsonParsers.asString(json['full_name'] ?? json['name']),
      studentNumber: JsonParsers.asNullableString(number),
      grade: JsonParsers.asString(json['grade']),
      phone: JsonParsers.asString(
        json['phone'] ?? json['student_phone'] ?? json['guardian_phone'],
      ),
      profileImage: JsonParsers.asNullableString(profile),
      dob: JsonParsers.asString(json['dob']),
      guardianName: JsonParsers.asString(json['guardian_name']),
      guardianPhone: JsonParsers.asString(json['guardian_phone']),
    );
  }
}
