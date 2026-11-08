import 'package:mr/core/utils/json_parsers.dart';

class AttendanceReportModel {
  final int total;
  final List<AttendanceRecordModel> records;

  const AttendanceReportModel({required this.total, required this.records});

  factory AttendanceReportModel.fromJson(Map<String, dynamic> json) {
    return AttendanceReportModel(
      total: JsonParsers.asIntOr(json['total'], 0),
      records: JsonParsers.asMapList(
        json['records'],
      ).map(AttendanceRecordModel.fromJson).toList(),
    );
  }
}

class AttendanceRecordModel {
  final int id;
  final String date;

  const AttendanceRecordModel({required this.id, required this.date});

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: JsonParsers.asIntOr(json['id'], 0),
      date: JsonParsers.asString(json['date']),
    );
  }
}
