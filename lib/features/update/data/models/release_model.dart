import 'package:mr/core/utils/json_parsers.dart';

/// Model for `GET /app/releases/latest`.
///
/// Only fields that the backend may return are parsed; unknown/missing fields
/// stay null/empty. New optional fields (`is_mandatory`, `sha256`,
/// `min_supported_version`) are parsed defensively so old backends keep working.
class ReleaseModel {
  final int? id;
  final int? versionCode;
  final String versionName;
  final String changelog;
  final String fileName;
  final int? fileSize;
  final String fileUrl;
  final String publishedAt;

  /// Optional backend fields. `null` means "not provided by the backend".
  final bool? isMandatory;
  final int? minSupportedVersionCode;
  final String? sha256;
  final bool isAvailable;

  const ReleaseModel({
    this.id,
    this.versionCode,
    this.versionName = '',
    this.changelog = '',
    this.fileName = '',
    this.fileSize,
    this.fileUrl = '',
    this.publishedAt = '',
    this.isMandatory,
    this.minSupportedVersionCode,
    this.sha256,
    this.isAvailable = true,
  });

  factory ReleaseModel.fromJson(Map<String, dynamic> json) {
    return ReleaseModel(
      id: JsonParsers.asInt(json['id']),
      versionCode: JsonParsers.asInt(json['version_code']),
      versionName: JsonParsers.asString(json['version_name']),
      changelog: JsonParsers.asString(json['changelog']),
      fileName: JsonParsers.asString(json['file_name']),
      fileSize: JsonParsers.asInt(json['file_size']),
      fileUrl: JsonParsers.asString(json['file_url']),
      publishedAt: JsonParsers.asString(json['published_at']),
      isMandatory: JsonParsers.asBool(json['is_mandatory']),
      minSupportedVersionCode: JsonParsers.asInt(json['min_supported_version']),
      sha256: JsonParsers.asNullableString(json['sha256']),
      isAvailable: _parseAvailability(json),
    );
  }

  /// Backwards compatible default: releases are mandatory unless the backend
  /// explicitly marks them optional.
  bool get mandatory => isMandatory ?? true;

  /// Returns an Arabic reason when the release cannot be used safely.
  String? get metadataError {
    final code = versionCode;
    if (code == null || code <= 0) {
      return 'بيانات الإصدار المنشور لا تحتوي version_code صالح.';
    }
    if (versionName.trim().isEmpty) {
      return 'بيانات الإصدار المنشور لا تحتوي version_name صالح.';
    }
    if (!isAvailable) {
      return 'هذا الإصدار غير متاح حاليًا.';
    }
    return null;
  }

  static bool _parseAvailability(Map<String, dynamic> json) {
    final explicit = JsonParsers.asBool(json['is_active']);
    if (explicit != null) return explicit;

    final status = JsonParsers.asString(json['status']).trim().toLowerCase();
    if (status == 'inactive' || status == 'disabled' || status == 'draft') {
      return false;
    }
    return true;
  }
}
