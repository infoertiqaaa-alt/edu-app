import 'package:flutter_test/flutter_test.dart';
import 'package:mr/features/update/data/models/release_model.dart';
import 'package:mr/features/update/domain/logic/update_comparator.dart';

void main() {
  group('UpdateComparator (authoritative rule = version_code)', () {
    test('backend(2) > installed(1) => mandatory update', () {
      expect(
        UpdateComparator.isUpdateRequired(
          installedVersionCode: 1,
          backendVersionCode: 2,
        ),
        isTrue,
      );
    });

    test('backend(1) == installed(1) => no update', () {
      expect(
        UpdateComparator.isUpdateRequired(
          installedVersionCode: 1,
          backendVersionCode: 1,
        ),
        isFalse,
      );
    });

    test('backend(1) < installed(2) => no downgrade / no update', () {
      expect(
        UpdateComparator.isUpdateRequired(
          installedVersionCode: 2,
          backendVersionCode: 1,
        ),
        isFalse,
      );
    });

    test('missing backend version_code => no forced update', () {
      expect(
        UpdateComparator.isUpdateRequired(
          installedVersionCode: 1,
          backendVersionCode: null,
        ),
        isFalse,
      );
    });

    test('missing installed version_code => no forced update', () {
      expect(
        UpdateComparator.isUpdateRequired(
          installedVersionCode: null,
          backendVersionCode: 9,
        ),
        isFalse,
      );
    });
  });

  group('ReleaseModel.fromJson', () {
    test('parses the real backend payload', () {
      const payload = {
        'id': 2,
        'version_code': 2,
        'version_name': '4.0.2',
        'changelog': '* Initial release',
        'file_name': 'app-v4.0.2.apk',
        'file_size': 93102427,
        'file_url':
            'https://mr-edu.ertiqaa.site/storage/releases/app-v4.0.2.apk',
        'published_at': '2026-09-12T08:08:38+00:00',
      };

      final release = ReleaseModel.fromJson(payload);

      expect(release.id, 2);
      expect(release.versionCode, 2);
      expect(release.versionName, '4.0.2');
      expect(release.changelog, '* Initial release');
      expect(release.fileName, 'app-v4.0.2.apk');
      expect(release.fileSize, 93102427);
      expect(
        release.fileUrl,
        'https://mr-edu.ertiqaa.site/storage/releases/app-v4.0.2.apk',
      );
    });

    test('handles missing fields safely', () {
      final release = ReleaseModel.fromJson(const {});

      expect(release.versionCode, isNull);
      expect(release.versionName, '');
      expect(release.changelog, '');
      expect(release.fileSize, isNull);
    });

    test('accepts version_code as a numeric string', () {
      final release = ReleaseModel.fromJson(const {'version_code': '3'});

      expect(release.versionCode, 3);
    });

    test('accepts version_code as a double', () {
      final release = ReleaseModel.fromJson(const {'version_code': 2.0});

      expect(release.versionCode, 2);
    });
  });
}
