import 'package:mr/core/utils/json_parsers.dart';

class StudentProfileModel {
  final int id;
  final String name;
  final String username;
  final String phone;
  final String email;
  final String qrCodeString;
  final String studentCode;
  final String grade;
  final String? profileImage;
  final String dob;
  final String guardianName;
  final String guardianPhone;

  const StudentProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.phone,
    required this.email,
    required this.qrCodeString,
    required this.studentCode,
    required this.grade,
    required this.profileImage,
    required this.dob,
    required this.guardianName,
    required this.guardianPhone,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: JsonParsers.asIntOr(json['id'], 0),
      name: JsonParsers.asString(json['name']),
      username: JsonParsers.asString(json['username']),
      phone: JsonParsers.asString(json['phone']),
      email: JsonParsers.asString(json['email']),
      qrCodeString: JsonParsers.asString(json['qr_code_string']),
      studentCode: JsonParsers.asString(json['student_code']),
      grade: JsonParsers.asString(json['grade']),
      profileImage: JsonParsers.asNullableString(json['profile_image']),
      dob: JsonParsers.asString(json['dob']),
      guardianName: JsonParsers.asString(json['guardian_name']),
      guardianPhone: JsonParsers.asString(json['guardian_phone']),
    );
  }
}
