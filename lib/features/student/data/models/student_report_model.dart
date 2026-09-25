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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      studentCode: json['student_code'] ?? '',
      grade: json['grade'] ?? '',
      groupName: json['group_name'] ?? '',
      profileImage: json['profile_image'],
    );
  }
}
