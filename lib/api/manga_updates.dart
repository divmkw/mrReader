import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

void main() async {
  final mu = MangaUpdates("One Piece");
  await mu.init();

  print("Title: ${mu.getTitle()}");
  print("Author: ${mu.getAuthor()}");
  print("Genres: ${mu.getGenres()}");
  print("Status: ${mu.getStatus(forTachiyomi: false)}");
  print("Thumbnail: ${mu.getThumbnailUrl()}");
}

class MangaUpdates {
  final String mangaName;
  static const String baseUrl = 'https://api.mangaupdates.com/v1/series/';

  late final Map<String, dynamic> manga;
  late final String description;
  late final String title;
  late final String alternativeName;
  late final String genres;
  late final List<dynamic> categories;
  late final List<dynamic> publishers;
  late final List<dynamic> authors;
  late final String thumbnailUrl;
  late final String type;
  late final String latestChapter;
  late final String status;
  late final bool completed;
  late final String year;

  MangaUpdates(this.mangaName);

  /// Initialize and load manga details
  Future<void> init() async {
    final mangaId = await _fetchMangaId(mangaName);
    manga = await _fetchMangaDetails(mangaId);

    description = manga["description"] ?? '';
    title = manga["title"] ?? '';
    alternativeName = (manga["associated"] as List?)
            ?.map((e) => e["title"])
            .join(', ') ??
        '';
    genres = (manga["genres"] as List?)
            ?.map((e) => e["genre"])
            .join(', ') ??
        '';
    categories = manga["categories"] ?? [];
    publishers = manga["publishers"] ?? [];
    authors = manga["authors"] ?? [];
    thumbnailUrl =
        manga["image"]?["url"]?["original"] ?? '';
    type = manga["type"] ?? '';
    latestChapter = manga["latest_chapter"]?.toString() ?? '';
    status = manga["status"] ?? '';
    completed = manga["completed"] ?? false;
    year = manga["year"]?.toString() ?? '';
  }

  /// === Public getters ===

  String getTitle() => title;

  String getDescription() => _parseDescription(description);

  String getType() => type;

  bool getIsCompleted() => completed;

  String getCategory() => _parseCategories(categories);

  String getAuthor() => _parseAuthors(authors);

  String getArtist() => _parseArtists(authors);

  String getAlternativeName() => alternativeName;

  dynamic getStatus({bool forTachiyomi = true}) =>
      _parseStatus(status, forTachiyomi);

  String getGenres({bool mixed = false}) {
    return mixed
        ? [genres, getCategory(), type]
            .where((e) => e.isNotEmpty)
            .join(', ')
        : genres;
  }

  String getYears() => year;

  String getThumbnailUrl() => thumbnailUrl;

  String getPublishers() => _parsePublishers(publishers);

  String getLastChapter() => latestChapter;

  /// === Private methods ===

  Future<String> _fetchMangaId(String name) async {
    final url = Uri.parse('${baseUrl}search');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'search': name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get manga ID');
    }

    final data = jsonDecode(response.body);
    final first = data['results'][0]['record'];
    return first['series_id'].toString();
  }

  Future<Map<String, dynamic>> _fetchMangaDetails(String mangaId) async {
    final url = Uri.parse('$baseUrl$mangaId');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to get manga details');
    }
    return jsonDecode(response.body);
  }

  String _parseDescription(String desc) {
    // Remove HTML-like tags
    final parts = desc.split('<');
    return parts.first.trim();
  }

  String _parseCategories(List<dynamic> categoryList) {
    if (categoryList.isEmpty) return '';
    int totalVotes = 0;

    for (final item in categoryList) {
      totalVotes += int.tryParse(item["votes"].toString()) ?? 0;
    }

    final avgVotes = (totalVotes / categoryList.length).toInt();
    final filtered = categoryList
        .where((item) =>
            (int.tryParse(item["votes"].toString()) ?? 0) > avgVotes)
        .map((item) => item["category"])
        .whereType<String>()
        .toList();

    return filtered.join(', ');
  }

  String _parseAuthors(List<dynamic> authorsList) {
    final filtered = authorsList
        .where((a) => a["type"] == "Author")
        .map((a) => a["name"])
        .whereType<String>()
        .toList();
    return filtered.join(', ');
  }

  String _parseArtists(List<dynamic> authorsList) {
    final filtered = authorsList
        .where((a) => a["type"] == "Artist")
        .map((a) => a["name"])
        .whereType<String>()
        .toList();
    return filtered.join(', ');
  }

  String _parsePublishers(List<dynamic> publishersList) {
    final filtered = publishersList
        .where((p) => p["type"] == "Original")
        .map((p) => p["publisher_name"])
        .whereType<String>()
        .toList();
    return filtered.join(', ');
  }

  dynamic _parseStatus(String s, bool forTachiyomi) {
    if (forTachiyomi) {
      if (completed) return 2;
      if (s.contains('Ongoing')) return 1;
      if (s.contains('Complete')) return 2;
      if (s.contains('Hiatus')) return 6;
      return 0;
    } else {
      if (completed) return 'Completed';
      if (s.contains('Ongoing')) return 'Ongoing';
      if (s.contains('Complete')) return 'Completed';
      if (s.contains('Hiatus')) return 'Hiatus';
      return 'UNKNOWN';
    }
  }

//   import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' as parser;

Future<void> fetchLatestReleases() async {
  final url = 'https://www.mangaupdates.com/series/6z1uqw7/solo-leveling';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Parse the HTML
      final document = parser.parse(response.body);

      // Look for the "Latest Release(s)" section
      final latestReleases = document.querySelectorAll('div:contains("Latest Release") ~ div a');

      if (latestReleases.isEmpty) {
        print('No releases found');
        return;
      }

      for (var release in latestReleases) {
        print(release.text.trim());
      }
    } else {
      print('Failed to load page. Status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

// void main() async {
//   await fetchLatestReleases();
// }
}
