/// نموذج الإصدار المرتد من `GET /app/releases/latest`.
///
/// الـ `data` جوه الاستجابة هو نفسه الـ map اللي بيمرناه هنا.
class ReleaseModel {
  final int? id;
  final int? versionCode;
  final String versionName;
  final String changelog;
  final String fileName;
  final int? fileSize;
  final String fileUrl;
  final String publishedAt;

  const ReleaseModel({
    this.id,
    this.versionCode,
    this.versionName = '',
    this.changelog = '',
    this.fileName = '',
    this.fileSize,
    this.fileUrl = '',
    this.publishedAt = '',
  });

  factory ReleaseModel.fromJson(Map<String, dynamic> json) {
    return ReleaseModel(
      id: _parseInt(json['id']),
      versionCode: _parseInt(json['version_code']),
      versionName: json['version_name']?.toString() ?? '',
      changelog: json['changelog']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      fileSize: _parseInt(json['file_size']),
      fileUrl: json['file_url']?.toString() ?? '',
      publishedAt: json['published_at']?.toString() ?? '',
    );
  }

  /// يقبل int أو double أو string ويرجع int صحيح بأمان، وإلا بيرجع null.
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
