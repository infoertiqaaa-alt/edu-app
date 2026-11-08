import 'package:mr/core/utils/json_parsers.dart';

/// Financial section of the student report.
///
/// The API currently returns only `total` with an empty `records` list and no
/// documented record schema. Each record keeps its raw JSON so future fields
/// are preserved without inventing a contract, and malformed entries are
/// skipped instead of crashing the whole report.
class FinancialReportModel {
  /// Kept as [num] because the backend may send an integer or a decimal/string.
  final num total;
  final List<FinancialRecordModel> records;

  const FinancialReportModel({required this.total, required this.records});

  factory FinancialReportModel.fromJson(Map<String, dynamic> json) {
    return FinancialReportModel(
      total: JsonParsers.asNumOr(json['total'], 0),
      records: JsonParsers.asMapList(
        json['records'],
      ).map(FinancialRecordModel.fromJson).toList(),
    );
  }
}

class FinancialRecordModel {
  final Map<String, dynamic> data;

  const FinancialRecordModel(this.data);

  factory FinancialRecordModel.fromJson(Map<String, dynamic> json) {
    return FinancialRecordModel(json);
  }
}
