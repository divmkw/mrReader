// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'manga_fetcher.dart';

// void main(){
//   MangaDexAPI.getChaptersByTitle('One Piece').then((chapters) {
//     for (var chapter in chapters) {
//       print('chapterid: ${chapter['id']}, Chapter: ${chapter['chapter']}, Title: ${chapter['title']}');
//       MangaDexApi.getChapterPages(chapter['id']).then((pages) {
//         for (var page in pages) {
//           print('Page: $page');
//         }
//       });
//     }
//   });
// }

// class MangaDexAPI {
//   static const baseUrl = 'api.mangadex.org';

//   // Step 1: Search manga by title to get its ID
//   static Future<String?> getMangaIdByTitle(String title) async {
//     final url = Uri.https(baseUrl, '/manga', {'title': title});
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['data'].isNotEmpty) {
//         return data['data'][0]['id']; // ✅ This is the UUID you need
//       }
//     }
//     return null;
//   }

//   // Step 2: Fetch chapters using that manga ID
//   static Future<List<Map<String, dynamic>>> getChapters(String mangaId) async {
//     final url = Uri.https(baseUrl, '/chapter', {
//       'manga': mangaId,
//       'translatedLanguage[]': 'en',
//       'order[chapter]': 'asc',
//       //'limit': '100',
//     });

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final chapters = (data['data'] as List).map((c) {
//         final attr = c['attributes'];
//         return {
//           'id': c['id'],
//           'chapter': attr['chapter'],
//           'title': attr['title'],
//         };
//       }).toList();
//       return chapters;
//     } else {
//       throw Exception(
//           'Failed to load chapters: ${response.statusCode} - ${response.body}');
//     }
//   }

//   // Combined convenience function
//   static Future<List<Map<String, dynamic>>> getChaptersByTitle(
//       String title) async {
//     final mangaId = await getMangaIdByTitle(title);
//     if (mangaId == null) throw Exception('Manga not found for "$title"');
//     return getChapters(mangaId);
//   }
// }
