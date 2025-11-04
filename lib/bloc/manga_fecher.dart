import 'dart:convert';
import 'package:http/http.dart' as http;

// void main (){
//   MangaDexApi.getTrendingManga().then((mangaList) {
//     for (var manga in mangaList) {
//       print('Title: ${manga['title']}, Cover URL: ${manga['coverUrl']}');
//     }
//   });
// }

class MangaDexApi {
  static const String baseUrl = 'https://api.mangadex.org';

  /// Fetch trending or popular manga
  static Future<List<Map<String, dynamic>>> getTrendingManga({int limit = 10}) async {
    final url = Uri.parse('$baseUrl/manga?limit=$limit&order[rating]=desc&includes[]=cover_art');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load manga');
    }

    final data = json.decode(response.body);
    final mangaList = <Map<String, dynamic>>[];

    print(data);

    for (var manga in data['data']) {
      final title = manga['attributes']['title']['en'] ??
          (manga['attributes']['title'].values.isNotEmpty ? manga['attributes']['title'].values.first : 'Unknown');
      final id = manga['id'];

      // Find cover art relationship
      final coverRel = manga['relationships'].firstWhere(
        (rel) => rel['type'] == 'cover_art',
        orElse: () => null,
      );
      final coverId = coverRel?['id'];

      final imageUrl = coverId != null
          ? 'https://uploads.mangadex.org/covers/$id/${coverId}.256.jpg'
          : 'https://via.placeholder.com/256x400?text=No+Cover';

      mangaList.add({
        'id': id,
        'title': title,
        'rating': manga['attributes']['contentRating'],
        'description': manga['attributes']['description']['en'] ?? '',
        'coverUrl': imageUrl,
      });
    }

    return mangaList;
  }

  /// Search for manga by title
  static Future<List<Map<String, dynamic>>> searchManga(String query, {int limit = 10}) async {
    final url = Uri.parse('$baseUrl/manga?title=$query&limit=$limit&includes[]=cover_art');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Search failed');
    }

    final data = json.decode(response.body);
    final mangaList = <Map<String, dynamic>>[];

    for (var manga in data['data']) {
      final title = manga['attributes']['title']['en'] ??
          (manga['attributes']['title'].values.isNotEmpty ? manga['attributes']['title'].values.first : 'Unknown');
      final id = manga['id'];

      final coverRel = manga['relationships'].firstWhere(
        (rel) => rel['type'] == 'cover_art',
        orElse: () => null,
      );
      final coverId = coverRel?['id'];

      final imageUrl = coverId != null
          ? 'https://uploads.mangadex.org/covers/$id/${coverId}.256.jpg'
          : 'https://via.placeholder.com/256x400?text=No+Cover';

      mangaList.add({
        'id': id,
        'title': title,
        'coverUrl': imageUrl,
      });
    }

    return mangaList;
  }
}
