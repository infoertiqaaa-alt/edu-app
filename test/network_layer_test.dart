import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr/core/network/api_response.dart';
import 'package:mr/core/network/dio_client.dart';
import 'package:mr/core/network/network_exceptions.dart';
import 'package:mr/core/session/session_manager.dart';
import 'package:mr/features/lessons/data/datasources/notes_database.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/in_memory_token_storage.dart';

/// Answers every request with [statusCode] and records what was sent.
class _StubAdapter implements HttpClientAdapter {
  final int statusCode;
  final List<RequestOptions> requests = [];

  _StubAdapter(this.statusCode);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'success': false, 'message': ''}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ApiResponse.requireData', () {
    String parseName(dynamic json) => (json as Map)['name'] as String;

    test('returns data for a successful response', () {
      final name = ApiResponse.requireData(
        {
          'success': true,
          'message': '',
          'data': {'name': 'MR'},
        },
        parseName,
        failureMessage: 'fallback',
      );
      expect(name, 'MR');
    });

    test('success:false surfaces the server message, not a null crash', () {
      expect(
        () => ApiResponse.requireData(
          {'success': false, 'message': 'الدرس غير موجود', 'data': null},
          parseName,
          failureMessage: 'fallback',
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'الدرس غير موجود',
          ),
        ),
      );
    });

    test('success:false without a message uses the Arabic fallback', () {
      final failure = NetworkExceptions.handle(
        _capture(
          () => ApiResponse.requireData(
            {'success': false},
            parseName,
            failureMessage: 'تعذر تحميل الدروس',
          ),
        ),
      );
      expect(failure.message, 'تعذر تحميل الدروس');
    });

    test('HTML/plain-text bodies and missing data become ParsingFailure', () {
      for (final body in <dynamic>[
        '<html>502</html>',
        null,
        {'success': true, 'message': ''},
      ]) {
        final failure = NetworkExceptions.handle(
          _capture(
            () => ApiResponse.requireData(
              body,
              parseName,
              failureMessage: 'fallback',
            ),
          ),
        );
        expect(failure, isA<ParsingFailure>(), reason: 'body: $body');
      }
    });
  });

  group('DioClient 401 handling', () {
    late InMemoryTokenStorage storage;
    late SessionManager sessionManager;
    late DioClient client;
    late List<SessionEvent> events;
    late StreamSubscription<SessionEvent> subscription;

    void useStatus(int statusCode, [_StubAdapter? adapter]) {
      client.dio.httpClientAdapter = adapter ?? _StubAdapter(statusCode);
    }

    setUp(() {
      storage = InMemoryTokenStorage()
        ..token = 'valid-token'
        ..role = 'student'
        ..userId = '42';
      sessionManager = SessionManager(storage);
      client = DioClient(storage, sessionManager);
      events = [];
      subscription = sessionManager.events.listen(events.add);
    });

    tearDown(() async {
      await subscription.cancel();
      await sessionManager.dispose();
    });

    test('401 on an authenticated endpoint expires the session once', () async {
      useStatus(401);

      await expectLater(
        client.dio.get('/student/profile'),
        throwsA(isA<DioException>()),
      );
      await pumpEventQueue();

      expect(storage.token, isNull);
      expect(storage.role, isNull);
      expect(storage.userId, isNull);
      expect(events, [isA<SessionExpired>()]);
    });

    test('401 on login is a credentials error and keeps the session', () async {
      useStatus(401);

      await expectLater(
        client.dio.post('/auth/login', data: {'username': 'u'}),
        throwsA(isA<DioException>()),
      );
      await pumpEventQueue();

      expect(storage.token, 'valid-token');
      expect(events, isEmpty);
    });

    test('401 on a skipAuth request (public APK download) never logs the '
        'user out', () async {
      useStatus(401);

      await expectLater(
        client.dio.get(
          'https://mr-edu.ertiqaa.site/storage/releases/app.apk',
          options: Options(extra: const {'skipAuth': true}),
        ),
        throwsA(isA<DioException>()),
      );
      await pumpEventQueue();

      expect(storage.token, 'valid-token');
      expect(events, isEmpty);
    });

    test('skipAuth requests never carry the bearer token', () async {
      final adapter = _StubAdapter(200);
      useStatus(200, adapter);

      await client.dio.get(
        'https://mr-edu.ertiqaa.site/storage/releases/app.apk',
        options: Options(extra: const {'skipAuth': true}),
      );
      await client.dio.get('/student/profile');

      expect(adapter.requests[0].headers['Authorization'], isNull);
      expect(
        adapter.requests[1].headers['Authorization'],
        'Bearer valid-token',
      );
    });
  });

  group('NotesDatabase', () {
    late Directory tempDir;

    setUp(() async {
      sqfliteFfiInit();
      tempDir = await Directory.systemTemp.createTemp('mr_notes_open_');
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('concurrent first callers share a single open', () async {
      final notes = NotesDatabase.forTesting(
        factory: databaseFactoryFfi,
        databasePath: p.join(tempDir.path, 'app.db'),
      );

      final results = await Future.wait([notes.database, notes.database]);

      expect(identical(results[0], results[1]), isTrue);
      await notes.close();
    });
  });
}

Object _capture(void Function() body) {
  try {
    body();
  } catch (error) {
    return error;
  }
  fail('expected an exception');
}
