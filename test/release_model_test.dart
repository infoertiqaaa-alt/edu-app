import 'package:flutter_test/flutter_test.dart';
import 'package:mr/features/update/data/models/release_model.dart';
import 'package:mr/features/update/data/services/release_download_url.dart';

void main() {
  group('ReleaseModel', () {
    test('parses the documented backend payload', () {
      final release = ReleaseModel.fromJson({
        'id': 10,
        'version_code': 10,
        'version_name': '4.0.10',
        'changelog': 'fixes',
        'file_name': 'app-v4.0.10.apk',
        'file_size': '5242880',
        'file_url': 'https://mr-edu.ertiqaa.site/storage/app.apk',
        'published_at': '2026-09-19T00:00:00+00:00',
      });

      expect(release.id, 10);
      expect(release.versionCode, 10);
      expect(release.versionName, '4.0.10');
      expect(release.fileSize, 5242880);
      expect(release.mandatory, isTrue);
      expect(release.metadataError, isNull);
    });

    test('parses optional hardening fields', () {
      final release = ReleaseModel.fromJson({
        'version_code': 12,
        'version_name': '4.0.12',
        'is_mandatory': false,
        'sha256': 'ABCDEF',
        'min_supported_version': 11,
      });

      expect(release.mandatory, isFalse);
      expect(release.sha256, 'ABCDEF');
      expect(release.minSupportedVersionCode, 11);
      expect(release.isAvailable, isTrue);
    });

    test('defaults to mandatory when the backend omits is_mandatory', () {
      final release = ReleaseModel.fromJson({
        'version_code': 2,
        'version_name': '2.0.0',
      });
      expect(release.mandatory, isTrue);
    });

    test('honours is_active=false and inactive status values', () {
      expect(
        ReleaseModel.fromJson({
          'version_code': 2,
          'version_name': '2.0.0',
          'is_active': false,
        }).isAvailable,
        isFalse,
      );
      expect(
        ReleaseModel.fromJson({
          'version_code': 2,
          'version_name': '2.0.0',
          'status': 'inactive',
        }).isAvailable,
        isFalse,
      );
    });

    test('reports unusable metadata instead of forcing a broken gate', () {
      expect(
        ReleaseModel.fromJson({'version_name': '2.0.0'}).metadataError,
        isNotNull,
      );
      expect(
        ReleaseModel.fromJson({'version_code': 2}).metadataError,
        isNotNull,
      );
      expect(
        ReleaseModel.fromJson({
          'version_code': 2,
          'version_name': '2.0.0',
          'is_active': false,
        }).metadataError,
        isNotNull,
      );
    });

    test('tolerates missing/blank values without throwing', () {
      final release = ReleaseModel.fromJson({});
      expect(release.versionCode, isNull);
      expect(release.versionName, '');
      expect(release.fileUrl, '');
      expect(release.sha256, isNull);
    });
  });

  group('ReleaseDownloadUrl', () {
    ReleaseModel withUrl(String url) =>
        ReleaseModel(versionCode: 7, versionName: '4.0.7', fileUrl: url);

    test('accepts trusted HTTPS APK URLs', () {
      expect(
        ReleaseDownloadUrl.resolve(
          withUrl('https://mr-edu.ertiqaa.site/storage/releases/app.apk'),
        ).toString(),
        'https://mr-edu.ertiqaa.site/storage/releases/app.apk',
      );
    });

    test('falls back to the backend endpoint when file_url is empty', () {
      expect(
        ReleaseDownloadUrl.resolve(withUrl('')).toString(),
        'https://mr-edu.ertiqaa.site/api/v1/app/releases/latest/download',
      );
    });

    test('rejects untrusted, non-HTTPS and non-APK URLs', () {
      expect(
        ReleaseDownloadUrl.resolve(
          withUrl('https://evil.example.com/app.apk'),
        ).toString(),
        'https://mr-edu.ertiqaa.site/api/v1/app/releases/latest/download',
      );
      expect(
        ReleaseDownloadUrl.resolve(
          withUrl('http://mr-edu.ertiqaa.site/storage/app.apk'),
        ).toString(),
        'https://mr-edu.ertiqaa.site/api/v1/app/releases/latest/download',
      );
      expect(
        ReleaseDownloadUrl.resolve(
          withUrl('https://mr-edu.ertiqaa.site/storage/app.txt'),
        ).toString(),
        'https://mr-edu.ertiqaa.site/api/v1/app/releases/latest/download',
      );
    });
  });
}
