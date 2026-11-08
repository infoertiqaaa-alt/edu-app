import 'package:mr/core/config/app_config.dart';
import 'package:mr/core/constants/api_constants.dart';

import '../models/release_model.dart';

/// Resolves the single, trusted download URL for a release.
///
/// Contract (matches docs/UPDATE_FLOW.md):
/// - A `file_url` that is HTTPS, on a trusted host and points to an `.apk`
///   file (or a `/download` endpoint) is used as-is.
/// - An empty or untrusted `file_url` is never downloaded; the backend
///   download endpoint `/app/releases/latest/download` is used instead.
/// - Whichever source is used, the file is only installed after
///   [ApkValidationService] has verified it against the release metadata.
class ReleaseDownloadUrl {
  ReleaseDownloadUrl._();

  static Uri? resolve(ReleaseModel release) {
    final raw = release.fileUrl.trim();

    if (raw.isNotEmpty) {
      final uri = Uri.tryParse(raw);
      // A valid, trusted `file_url` wins; anything else falls back to the
      // backend download endpoint instead of downloading from an unexpected
      // location.
      if (_isValid(uri)) return uri;
    }

    final fallback = Uri.tryParse(ApiConstants.latestReleaseDownloadUrl);
    return _isValid(fallback) ? fallback : null;
  }

  static bool _isValid(Uri? uri) {
    if (uri == null) return false;
    if (uri.scheme != 'https') return false;
    if (uri.host.isEmpty) return false;
    if (!AppConfig.isAllowedDownloadHost(uri.host)) return false;
    if (!uri.path.toLowerCase().endsWith('.apk') &&
        !uri.path.toLowerCase().endsWith('/download')) {
      return false;
    }
    return true;
  }
}
