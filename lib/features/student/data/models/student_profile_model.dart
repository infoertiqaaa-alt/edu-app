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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      qrCodeString: json['qr_code_string'] ?? '',
      studentCode: json['student_code'] ?? '',
      grade: json['grade'] ?? '',
      profileImage: json['profile_image'],
      dob: json['dob'] ?? '',
      guardianName: json['guardian_name'] ?? '',
      guardianPhone: json['guardian_phone'] ?? '',
    );
  }
}