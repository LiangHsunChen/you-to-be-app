import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeService {
  final String apiKey;
  YoutubeService(this.apiKey);

  Future<List<YoutubeVideo>> searchVideos(String query, {int maxResults = 3}) async {
    final url = Uri.https('www.googleapis.com', '/youtube/v3/search', {
      'part': 'snippet',
      'q': query,
      'type': 'video',
      'maxResults': maxResults.toString(),
      'order': 'relevance',
      'key': apiKey,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>;
      final videos = items.map((item) => YoutubeVideo.fromJson(item)).toList();
      // Fetch durations for all video IDs
      if (videos.isNotEmpty) {
        final ids = videos.map((v) => v.videoId).join(',');
        final detailsUrl = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
          'part': 'contentDetails',
          'id': ids,
          'key': apiKey,
        });
        final detailsResponse = await http.get(detailsUrl);
        if (detailsResponse.statusCode == 200) {
          final detailsData = json.decode(detailsResponse.body);
          final detailsItems = detailsData['items'] as List<dynamic>;
          final Map<String, String> idToDuration = {
            for (var item in detailsItems)
              item['id'] as String: item['contentDetails']['duration'] as String
          };
          for (final v in videos) {
            v.duration = idToDuration[v.videoId] ?? '';
          }
        }
      }
      return videos;
    } else {
      throw Exception('Failed to fetch YouTube videos');
    }
  }
}

class YoutubeVideo {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  String duration; // ISO 8601 duration, e.g. PT1H2M3S

  YoutubeVideo({required this.videoId, required this.title, required this.thumbnailUrl, this.duration = ''});

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    return YoutubeVideo(
      videoId: json['id']['videoId'] as String,
      title: json['snippet']['title'] as String,
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'] as String,
    );
  }

  String get formattedDuration {
    if (duration.isEmpty) return '';
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);
    if (match == null) return '';
    final h = int.tryParse(match.group(1) ?? '') ?? 0;
    final m = int.tryParse(match.group(2) ?? '') ?? 0;
    final s = int.tryParse(match.group(3) ?? '') ?? 0;
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    if (h > 0) {
      return '${h}:${twoDigits(m)}:${twoDigits(s)}';
    } else {
      return '${m}:${twoDigits(s)}';
    }
  }
}
