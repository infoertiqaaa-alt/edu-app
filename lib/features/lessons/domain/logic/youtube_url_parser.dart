/// Extracts a YouTube video id from the supported URL formats.
///
/// Returns `null` for missing, malformed or non-YouTube URLs. This is
/// deliberately strict so a lesson can never silently play an unrelated video.
class YoutubeUrlParser {
  YoutubeUrlParser._();

  static final RegExp _videoIdPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

  static const Set<String> _youtubeHosts = {
    'youtube.com',
    'www.youtube.com',
    'm.youtube.com',
    'music.youtube.com',
    'youtube-nocookie.com',
    'www.youtube-nocookie.com',
    'youtu.be',
    'www.youtu.be',
  };

  static String? extractVideoId(String? rawUrl) {
    final raw = rawUrl?.trim();
    if (raw == null || raw.isEmpty) return null;

    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    final host = uri.host.toLowerCase();
    if (!_youtubeHosts.contains(host)) return null;

    String? candidate;

    if (host == 'youtu.be' || host == 'www.youtu.be') {
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) candidate = segments.first;
    } else {
      final queryId = uri.queryParameters['v'];
      if (queryId != null && queryId.isNotEmpty) {
        candidate = queryId;
      } else {
        final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
        if (segments.length >= 2) {
          switch (segments.first) {
            case 'embed':
            case 'shorts':
            case 'live':
            case 'v':
              candidate = segments[1];
          }
        }
      }
    }

    if (candidate == null) return null;

    // Strip a trailing fragment/query accidentally included in the path.
    final cleaned = candidate.split(RegExp(r'[?&#]')).first;
    return _videoIdPattern.hasMatch(cleaned) ? cleaned : null;
  }
}
