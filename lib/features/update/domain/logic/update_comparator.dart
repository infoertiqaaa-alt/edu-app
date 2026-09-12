/// المقارنة الرسمية لتحديد لزوم التحديث الإجباري.
///
/// الـ version_code هو المرجع الوحيد.
class UpdateComparator {
  UpdateComparator._();

  /// بيحتاج تحديث إجباري لو نسخة الخادم أكبر من النسخة المثبتة فعليًا.
  static bool isUpdateRequired({
    required int? installedVersionCode,
    required int? backendVersionCode,
  }) {
    if (installedVersionCode == null || backendVersionCode == null) {
      return false;
    }
    return backendVersionCode > installedVersionCode;
  }
}
