class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://mr-edu.ertiqaa.site/api/v1';

  static const String storageBaseUrl = 'https://mr-edu.ertiqaa.site/storage';

  /// بتحوّل المسار النسبي اللي بترجعه الـ API (زي `student-profiles/x.jpg`)
  /// لـ URL كامل جاهز للعرض، وبتسيب الـ URLs الكاملة زي ما هي.
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

  // App release / update endpoints (client reads these, never publishes)
  static const String latestRelease = '/app/releases/latest';
  static const String latestReleaseDownload = '/app/releases/latest/download';
}
