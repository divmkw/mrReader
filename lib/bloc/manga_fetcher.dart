import 'dart:convert';
// import 'dart:developer';
import 'package:http/http.dart' as http;

void main (){
  MangaDexApi.getTrendingManga().then((mangaList) {
    for (var manga in mangaList) {
      print('Title: ${manga['title']}, Cover URL: ${manga['coverUrl']}');
    }
  });
}

class MangaDexApi {
  static const String baseUrl = 'https://api.mangadex.org';

  /// Fetch trending or popular manga
  static Future<List<Map<String, dynamic>>> getTrendingManga({int limit = 10}) async {
    // Using followedCount for popularity; include cover art and filter to EN and safe/suggestive content
    final url = Uri.parse('$baseUrl/manga?&order[followedCount]=desc&includes[]=cover_art&includes[]=author&availableTranslatedLanguage[]=en&contentRating[]=safe&contentRating[]=suggestive');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load manga: HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final pendingWithRatings = <Future<Map<String, dynamic>>>[];

    // print(data);

    for (var manga in data['data']) {
      final title = manga['attributes']['title']['en'] ??
          (manga['attributes']['title'].values.isNotEmpty ? manga['attributes']['title'].values.first : 'Unknown');
      final id = manga['id'];
      
      // Find cover art relationship
      final coverRel = manga['relationships'].firstWhere(
        (rel) => rel['type'] == 'cover_art',
        orElse: () => null,
      );
      // Find author relationship (present due to includes[]=author)
      final authorRel = manga['relationships'].firstWhere(
        (rel) => rel['type'] == 'author',
        orElse: () => null,
      );
      final fileName = coverRel?['attributes']?['fileName'];
      final authorName = authorRel?['attributes']?['name'] ?? 'Unknown';

      final imageUrl = fileName != null
          ? 'https://uploads.mangadex.org/covers/$id/$fileName'
          : 'https://via.placeholder.com/256x400?text=No+Cover';

      final futureItem = getMangaRating(id).then((rating) => {
        'id': id,
        'title': title,
        'author': authorName,
        'contentRating': manga['attributes']['contentRating'],
        'description': manga['attributes']['description']['en'] ?? '',
        'chapters': manga['attributes']['lastChapter'] ?? 0,
        'rating': rating ?? 0.0,
        'coverUrl': imageUrl,
      });
      pendingWithRatings.add(futureItem);
    }
    final mangaList = await Future.wait(pendingWithRatings);
    return mangaList;
  }

  /// Search for manga by title
  static Future<List<Map<String, dynamic>>> searchManga(String query, {int limit = 10}) async {
    final url = Uri.parse('$baseUrl/manga?title=$query&limit=$limit&includes[]=cover_art&includes[]=author');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Search failed');
    }

    final data = json.decode(response.body);
    final pendingWithRatings = <Future<Map<String, dynamic>>>[];

    for (var manga in data['data']) {
      final title = manga['attributes']['title']['en'] ??
          (manga['attributes']['title'].values.isNotEmpty ? manga['attributes']['title'].values.first : 'Unknown');
      final id = manga['id'];

      final coverRel = manga['relationships'].firstWhere(
        (rel) => rel['type'] == 'cover_art',
        orElse: () => null,
      );
      final fileName = coverRel?['attributes']?['fileName'];
      final authorRel = manga['relationships'].firstWhere(
        (rel) => rel['type'] == 'author',
        orElse: () => null,
      );
      final author = authorRel?['attributes']?['name'] ?? 'Unknown';

      final imageUrl = fileName != null
          ? 'https://uploads.mangadex.org/covers/$id/$fileName'
          : 'https://via.placeholder.com/256x400?text=No+Cover';

      final futureItem = getMangaRating(id).then((rating) => {
        'id': id,
        'title': title,
        'author': author,
        'description': manga['attributes']['description']?['en'] ?? '',
        'chapters': manga['attributes']['lastChapter'] ?? 0,
        'rating': rating ?? 0.0,
        'coverUrl': imageUrl,
      });
      pendingWithRatings.add(futureItem);
    }

    final mangaList = await Future.wait(pendingWithRatings);
    return mangaList;
  }
  /// Get manga rating from statistics endpoint
  static Future<double?> getMangaRating(String mangaId) async {
    final url = Uri.parse('$baseUrl/statistics/manga/$mangaId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stats = data['statistics'][mangaId];
      final rating = stats['rating']['bayesian'] ?? stats['rating']['average'];
      return rating?.toDouble();
    } else {
      print('Failed to load rating: ${response.statusCode}');
      return null;
    }
  }

  // 🔹 Fetch chapters
  static Future<List<Map<String, dynamic>>> getChapters(String mangaId) async {
    final url = Uri.parse('$baseUrl/chapter?manga=$mangaId&translatedLanguage[]=en&order[chapter]=asc');

    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final chapters = (data['data'] as List).map((c) {
        final attr = c['attributes'];
        return {
          'id': c['id'],
          'chapter': attr['chapter'],
          'title': attr['title'],
        };
      }).toList();
      return chapters;
    } else {
      throw Exception('Failed to load chapters');
    }
  }

  // 🔹 Fetch image URLs for one chapter
  static Future<List<String>> getChapterPages(String chapterId) async {
    final url = Uri.parse('$baseUrl/at-home/server/$chapterId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final baseUrl = data['baseUrl'];
      final hash = data['chapter']['hash'];
      final files = List<String>.from(data['chapter']['data']);
      print(files) ;
      return files.map((f) => '$baseUrl/data/$hash/$f').toList();
    } else {
      throw Exception('Failed to load pages');
    }
  }
  // Future<List<String>> _loadFirstChapter(String mangaId) async {
  //   final chapters = await MangaDexApi.getChapters(mangaId);
  //   if (chapters.isEmpty) throw Exception('No chapters found for this manga.');
  //   final firstChapterId = chapters.last['id']; // or .first for oldest
  //   return MangaDexApi.getChapterPages(firstChapterId); // or .first for oldest
  // }


}

