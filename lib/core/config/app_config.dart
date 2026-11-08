/// Build-time application configuration.
///
/// Values are injected with `--dart-define` so the same source tree can be
/// built for development, staging and production without editing Dart files.
///
/// Production is the safe default: a plain `flutter build apk --release`
/// without any defines keeps pointing at the existing production backend.
enum AppEnvironment { development, staging, production }

class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // Compile-time values
  // ---------------------------------------------------------------------------

  static const String _environmentRaw = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  static const String _storageBaseUrlOverride = String.fromEnvironment(
    'STORAGE_BASE_URL',
  );

  static const String _downloadHostsRaw = String.fromEnvironment(
    'DOWNLOAD_HOSTS',
  );

  static const bool allowInsecureHttp = bool.fromEnvironment(
    'ALLOW_INSECURE_HTTP',
    defaultValue: false,
  );

  static const String _productionApiBaseUrl =
      'https://mr-edu.ertiqaa.site/api/v1';
  static const String _productionStorageBaseUrl =
      'https://mr-edu.ertiqaa.site/storage';

  // ---------------------------------------------------------------------------
  // Resolved configuration
  // ---------------------------------------------------------------------------

  static AppEnvironment get environment {
    switch (_environmentRaw.trim().toLowerCase()) {
      case 'development':
      case 'dev':
        return AppEnvironment.development;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      default:
        throw StateError(
          'قيمة APP_ENV غير معروفة: "$_environmentRaw". '
          'القيم المسموحة: development, staging, production.',
        );
    }
  }

  static String get environmentName => environment.name;

  static bool get isProduction => environment == AppEnvironment.production;

  /// Base URL of the REST API, always without a trailing slash.
  static String get apiBaseUrl {
    final override = _apiBaseUrlOverride.trim();
    if (override.isNotEmpty) return _normalizeBaseUrl(override);

    if (isProduction) return _productionApiBaseUrl;

    throw StateError(
      'API_BASE_URL مطلوب لبيئة ${environment.name}. '
      'مثال: --dart-define=APP_ENV=development '
      '--dart-define=API_BASE_URL=https://dev.example.com/api/v1',
    );
  }

  /// Base URL used to resolve relative storage paths (images, APK files).
  static String get storageBaseUrl {
    final override = _storageBaseUrlOverride.trim();
    if (override.isNotEmpty) return _normalizeBaseUrl(override);

    if (isProduction) return _productionStorageBaseUrl;

    // Staging/development must be explicit rather than silently hitting
    // production storage.
    throw StateError('STORAGE_BASE_URL مطلوب لبيئة ${environment.name}.');
  }

  /// Hosts that are allowed as sources for the update APK.
  ///
  /// The API/storage hosts are trusted by default. Extra hosts (for example a
  /// CDN) can be supplied at build time:
  /// `--dart-define=DOWNLOAD_HOSTS=cdn.example.com`.
  static Set<String> get allowedDownloadHosts {
    final hosts = <String>{
      Uri.parse(_effectiveUri(apiBaseUrl, 'API_BASE_URL')).host,
      Uri.parse(_effectiveUri(storageBaseUrl, 'STORAGE_BASE_URL')).host,
    };

    for (final raw in _downloadHostsRaw.split(',')) {
      final host = raw.trim().toLowerCase();
      if (host.isNotEmpty) hosts.add(host);
    }

    hosts.removeWhere((host) => host.isEmpty);
    return hosts;
  }

  static bool isAllowedDownloadHost(String host) {
    return allowedDownloadHosts.contains(host.trim().toLowerCase());
  }

  /// Fails fast on invalid environment configuration.
  static void validate() {
    // Accessing the getters also validates the environment/override rules.
    final api = Uri.tryParse(apiBaseUrl);
    final storage = Uri.tryParse(storageBaseUrl);

    if (api == null || !api.hasScheme || api.host.isEmpty) {
      throw StateError('API_BASE_URL غير صالح: "$apiBaseUrl".');
    }
    if (storage == null || !storage.hasScheme || storage.host.isEmpty) {
      throw StateError('STORAGE_BASE_URL غير صالح: "$storageBaseUrl".');
    }

    _requireSecureScheme(api, 'API_BASE_URL');
    _requireSecureScheme(storage, 'STORAGE_BASE_URL');

    if (isProduction) {
      if (api.host == 'localhost' || api.host == '127.0.0.1') {
        throw StateError('لا يمكن استخدام localhost في بيئة الإنتاج.');
      }
      if (api.scheme != 'https' || storage.scheme != 'https') {
        throw StateError('بيئة الإنتاج تتطلب HTTPS فقط.');
      }
    }
  }

  static void _requireSecureScheme(Uri uri, String name) {
    if (uri.scheme == 'https') return;
    if (allowInsecureHttp && !isProduction) return;
    throw StateError('$name يجب أن يستخدم HTTPS.');
  }

  static String _effectiveUri(String value, String name) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('$name غير صالح: "$value".');
    }
    return value;
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
