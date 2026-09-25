import 'attendance_report_model.dart';
import 'financial_report_model.dart';
import 'student_report_model.dart';

class ReportsModel {
  final StudentReportModel? student;
  final AttendanceReportModel? attendance;
  final FinancialReportModel? financials;

  const ReportsModel({this.student, this.attendance, this.financials});

  factory ReportsModel.fromJson(Map<String, dynamic> json) {
    final studentJson = json['student'];
    final attendanceJson = json['attendance'];
    final financialsJson = json['financials'];
    return ReportsModel(
      student: studentJson is Map<String, dynamic>
          ? StudentReportModel.fromJson(studentJson)
          : null,
      attendance: attendanceJson is Map<String, dynamic>
          ? AttendanceReportModel.fromJson(attendanceJson)
          : null,
      financials: financialsJson is Map<String, dynamic>
          ? FinancialReportModel.fromJson(financialsJson)
          : null,
    );
  }
}
