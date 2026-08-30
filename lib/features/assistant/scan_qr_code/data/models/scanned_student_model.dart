/// بيانات الطالب اللي بترجع بعد مسح الـ QR
/// TODO: عدّل أسماء المفاتيح (keys) هنا لو شكل الـ JSON الحقيقي مختلف عن اللي مفترضه
class ScannedStudentModel {
  final int id;
  final String name;
  final String? studentNumber; // "رقم الطالب #10245" الظاهر في التصميم
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
    return ScannedStudentModel(
      id: _asInt(json['student_id'] ?? json['id']),
      name: (json['full_name'] ?? json['name'] ?? '').toString(),
      // TODO: تأكد المفتاح ده student_number ولا student_code ولا حاجة تانية
      studentNumber:
          json['student_number']?.toString() ?? json['student_code']?.toString(),
      grade: (json['grade'] ?? '').toString(),
      phone: json['phone']?.toString() ??
          json['student_phone']?.toString() ??
          json['guardian_phone']?.toString() ??
          '',
      profileImage: json['profile_image']?.toString(),
      dob: (json['dob'] ?? '').toString(),
      guardianName: (json['guardian_name'] ?? '').toString(),
      guardianPhone: (json['guardian_phone'] ?? '').toString(),
    );
  }

  static int _asInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}
