class AttendanceReportModel {
  final int total;
  final List<AttendanceRecordModel> records;

  const AttendanceReportModel({required this.total, required this.records});

  factory AttendanceReportModel.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'];
    return AttendanceReportModel(
      total: json['total'] ?? 0,
      records: recordsJson is List
          ? recordsJson
                .map(
                  (e) =>
                      AttendanceRecordModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : const [],
    );
  }
}

class AttendanceRecordModel {
  final int id;
  final String date;

  const AttendanceRecordModel({required this.id, required this.date});

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(id: json['id'] ?? 0, date: json['date'] ?? '');
  }
}
