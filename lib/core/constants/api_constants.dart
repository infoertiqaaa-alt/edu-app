import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  /// Single source of truth: build-time configuration (`app_config.dart`).
  static String get baseUrl => AppConfig.apiBaseUrl;

  static String get storageBaseUrl => AppConfig.storageBaseUrl;

  /// Converts the relative path returned by the API (e.g. `student-profiles/x.jpg`)
  /// into a full display URL, leaving absolute URLs untouched.
  static String? resolveImageUrl(String? path) {
    final trimmed = path?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return '$storageBaseUrl/${trimmed.replaceFirst(RegExp(r'^/+'), '')}';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String login = '/auth/login';
  static const String studentProfile = '/student/profile';
  static String scanStudentByQr(String qrCodeString) =>
      '/assistant/student/scan/${Uri.encodeComponent(qrCodeString)}';
  static const String registerAttendance = '/assistant/attendance/register';
  static const String lessons = '/student/lessons';
  static const String studentReports = '/student/reports';

  // App release / update endpoints (client reads these, never publishes)
  static const String latestRelease = '/app/releases/latest';
  static const String latestReleaseDownload = '/app/releases/latest/download';

  /// Absolute fallback download URL used only when the release metadata does
  /// not contain a usable `file_url`.
  static String get latestReleaseDownloadUrl =>
      '$baseUrl$latestReleaseDownload';
}
