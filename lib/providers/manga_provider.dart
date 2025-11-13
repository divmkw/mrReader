import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/manga_fetcher.dart';

/// --- Fetch chapters from MangaDex ---
 
final trendingMangaProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await MangaDexApi.getTrendingManga();
});

 
final chaptersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, mangaId) async {
  return await MangaDexApi.getChapters(mangaId);
});

/// --- Bookmark state management ---
final bookmarkProvider = Provider.family<BookmarkNotifier, String>((ref, mangaId) {
  return BookmarkNotifier(mangaId);
});

class BookmarkNotifier extends ChangeNotifier {
  final String mangaId;
  bool _isBookmarked = false;

  BookmarkNotifier(this.mangaId) {
    _load();
  }

  bool get isBookmarked => _isBookmarked;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('bookmarks');
    if (raw == null) return;
    try {
      final List list = jsonDecode(raw);
      final exists = list.any((e) => e['id'] == mangaId);
      _isBookmarked = exists;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleBookmark(Map<String, dynamic> manga) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('bookmarks');
    List<dynamic> list;
    try {
      list = raw != null ? jsonDecode(raw) : <dynamic>[];
    } catch (_) {
      list = <dynamic>[];
    }

    if (_isBookmarked) {
      // Remove
      list.removeWhere((e) => e['id'] == mangaId);
    } else {
      list.add({
        ...manga,
        'savedAt': DateTime.now().toIso8601String(),
      });
    }

    await prefs.setString('bookmarks', jsonEncode(list));
    _isBookmarked = !_isBookmarked;
    // _load();
    notifyListeners();
  }
}

/// --- Last Read chapter persistence ---
final lastReadProvider = Provider.family<LastReadNotifier, String>((ref, mangaId) {
  return LastReadNotifier(mangaId);
});

class LastReadNotifier extends ChangeNotifier {
  final String mangaId;
  int _lastReadIndex = 0;

  LastReadNotifier(this.mangaId) {
    _load();
  }

  int get lastReadIndex => _lastReadIndex;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _lastReadIndex = prefs.getInt('lastRead_$mangaId') ?? 0;
    notifyListeners();
  }

  Future<void> updateLastRead(int chapterIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastRead_$mangaId', chapterIndex);
    _lastReadIndex = chapterIndex;
    notifyListeners();
  }
}





// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../bloc/manga_fetcher.dart';

// final trendingMangaProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
//   return await MangaDexApi.getTrendingManga();
// });
