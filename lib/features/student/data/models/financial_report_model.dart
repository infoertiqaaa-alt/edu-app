/// الشؤون المالية في تقرير الطالب.
///
/// حاليًا الـ API بيرجع فقط `total` مع `records` فاضية، من غير أي حقول
/// معرّفة للسجل الواحد. عشان كده كل سجل بيتخزن كـ [FinancialRecordModel]
/// يحافظ على الـ JSON الخام من غير اختراع حقول جديدة، وبكده أي حقول
/// هتترجع في المستقبل هتظهر من غير ما نكسر البارسينج الحالي.
class FinancialReportModel {
  final int total;
  final List<FinancialRecordModel> records;

  const FinancialReportModel({required this.total, required this.records});

  factory FinancialReportModel.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'];
    return FinancialReportModel(
      total: json['total'] ?? 0,
      records: recordsJson is List
          ? recordsJson
                .map(
                  (e) =>
                      FinancialRecordModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : const [],
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
