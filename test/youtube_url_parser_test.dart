import 'package:flutter_test/flutter_test.dart';
import 'package:mr/features/lessons/domain/logic/youtube_url_parser.dart';

void main() {
  group('YoutubeUrlParser', () {
    test('extracts id from a standard watch URL', () {
      expect(
        YoutubeUrlParser.extractVideoId(
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
    });

    test('extracts id with extra query parameters', () {
      expect(
        YoutubeUrlParser.extractVideoId(
          'https://www.youtube.com/watch?feature=share&v=dQw4w9WgXcQ&t=10s',
        ),
        'dQw4w9WgXcQ',
      );
    });

    test('extracts id from youtu.be short links', () {
      expect(
        YoutubeUrlParser.extractVideoId('https://youtu.be/dQw4w9WgXcQ?t=5'),
        'dQw4w9WgXcQ',
      );
    });

    test('extracts id from shorts, embed, live and music URLs', () {
      expect(
        YoutubeUrlParser.extractVideoId(
          'https://youtube.com/shorts/dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
      expect(
        YoutubeUrlParser.extractVideoId(
          'https://www.youtube.com/embed/dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
      expect(
        YoutubeUrlParser.extractVideoId(
          'https://www.youtube.com/live/dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
      expect(
        YoutubeUrlParser.extractVideoId(
          'https://music.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        'dQw4w9WgXcQ',
      );
    });

    test('rejects null, blank and malformed values', () {
      expect(YoutubeUrlParser.extractVideoId(null), isNull);
      expect(YoutubeUrlParser.extractVideoId(''), isNull);
      expect(YoutubeUrlParser.extractVideoId('not a url'), isNull);
      expect(
        YoutubeUrlParser.extractVideoId(
          'https://www.youtube.com/watch?v=short',
        ),
        isNull,
      );
      expect(
        YoutubeUrlParser.extractVideoId(
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ<script>',
        ),
        isNull,
      );
    });

    test('rejects non-YouTube hosts and non-http schemes', () {
      expect(
        YoutubeUrlParser.extractVideoId(
          'https://evil.example.com/watch?v=dQw4w9WgXcQ',
        ),
        isNull,
      );
      expect(
        YoutubeUrlParser.extractVideoId(
          'javascript:alert(1)//youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        isNull,
      );
    });

    test('does not fall back to a hardcoded demo video', () {
      // Regression guard: the old implementation played a fixed lesson video
      // when the backend URL was empty. That data leak must not come back.
      expect(YoutubeUrlParser.extractVideoId(''), isNot('AEHJqatke6E'));
      expect(YoutubeUrlParser.extractVideoId(null), isNot('AEHJqatke6E'));
    });
  });
}
