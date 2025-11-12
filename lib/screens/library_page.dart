import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../widgets/manga_card.dart';

/// --- PROVIDERS ---

/// Provider for fetching and caching bookmarks
final bookmarksProvider =
    AsyncNotifierProvider<BookmarksNotifier, List<Map<String, dynamic>>>(
  () => BookmarksNotifier(),
);

/// --- NOTIFIER LOGIC ---

class BookmarksNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    return await _loadBookmarks();
  }

  /// Load bookmarks from SharedPreferences
  Future<List<Map<String, dynamic>>> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('bookmarks');
      if (raw == null) {
        return [];
      }
      final List<Map<String, dynamic>> list = (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return list;
    } catch (e) {
      throw Exception('Failed to load bookmarks: $e');
    }
  }

  /// Refresh bookmarks
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final bookmarks = await _loadBookmarks();
      state = AsyncData(bookmarks);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Clear all bookmarks
  Future<void> clearBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bookmarks');
    state = const AsyncData([]);
  }
}

/// --- MAIN PAGE ---

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Library'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Clear all bookmarks',
              onPressed: () =>
                  ref.read(bookmarksProvider.notifier).clearBookmarks(),
            ),
          ],
        ),
        body: bookmarksAsync.when(
          data: (bookmarks) {
            if (bookmarks.isEmpty) return const _EmptyLibraryView();
            return _BookmarksGrid(bookmarks: bookmarks);
          },
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (err, _) => Center(
            child: Text('Error loading bookmarks: $err'),
          ),
        ),
      ),
    );
  }
}

/// --- WIDGETS ---

class _EmptyLibraryView extends StatelessWidget {
  const _EmptyLibraryView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text('No Bookmarks Yet', style: TextStyle(fontSize: 18)),
          SizedBox(height: 5),
          Text(
            'Bookmark your favorite manga to access them quickly',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BookmarksGrid extends ConsumerWidget {
  final List<Map<String, dynamic>> bookmarks;

  const _BookmarksGrid({required this.bookmarks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async =>
          await ref.read(bookmarksProvider.notifier).refresh(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: bookmarks.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 270,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final m = bookmarks[index];
            final rating = double.tryParse('${m['rating']}') ?? 0.0;
            final chapters = int.tryParse('${m['chapters']}') ?? 0;
            final imageUrl = (m['imageUrl']?.toString().isNotEmpty ?? false)
                ? m['imageUrl'].toString()
                : 'https://orv.pages.dev/assets/covers/orv.webp';

            return MangaCard(
              id: (m['id'] ?? m['title'] ?? '0').toString(),
              title: (m['title'] ?? 'Unknown').toString(),
              author: (m['author'] ?? 'Unknown').toString(),
              imageUrl: imageUrl,
              rating: rating,
              chapters: chapters,
              description: (m['description'] ?? '').toString(),
            );
          },
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../widgets/manga_card.dart';

// class LibraryPage extends StatefulWidget {
//   const LibraryPage({super.key});

//   @override
//   State<LibraryPage> createState() => _LibraryPageState();
// }

// class _LibraryPageState extends State<LibraryPage> {
//   List<Map<String, dynamic>> _bookmarks = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadBookmarks();
//   }

//   Future<void> _loadBookmarks() async {
//     setState(() => _loading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final raw = prefs.getString('bookmarks');
//       if (raw == null) {
//         setState(() {
//           _bookmarks = [];
//           _loading = false;
//         });
//         return;
//       }
//       final List<dynamic> parsed = jsonDecode(raw) as List<dynamic>;
//       final list = parsed.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
//       setState(() {
//         _bookmarks = list;
//         _loading = false;
//       });
//     } catch (_) {
//       setState(() {
//         _bookmarks = [];
//         _loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const SafeArea(child: Center(child: CircularProgressIndicator()));
//     }

//     if (_bookmarks.isEmpty) {
//       return const SafeArea(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
//               SizedBox(height: 10),
//               Text('No Bookmarks Yet', style: TextStyle(fontSize: 18)),
//               SizedBox(height: 5),
//               Text('Bookmark your favorite manga to access them quickly', style: TextStyle(color: Colors.grey)),
//             ],
//           ),
//         ),
//       );
//     }

//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: RefreshIndicator(
//           onRefresh: _loadBookmarks,
//           child: GridView.builder(
//             itemCount: _bookmarks.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               mainAxisExtent: 270,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//             ),
//             itemBuilder: (context, index) {
//               final m = _bookmarks[index];
//               final dynamic rawRating = m['rating'];
//               final double rating = rawRating is num
//                   ? rawRating.toDouble()
//                   : (rawRating is String ? double.tryParse(rawRating) ?? 0.0 : 0.0);
//               final double displayRating = double.parse(rating.toStringAsFixed(2));

//               final dynamic rawCh = m['chapters'];
//               final int chapters = rawCh is int
//                   ? rawCh
//                   : (rawCh is String ? int.tryParse(rawCh) ?? 0 : 0);

//               return MangaCard(
//                 id: (m['title'] ?? '0').toString(),
//                 title: (m['title'] ?? 'Unknown').toString(),
//                 author: (m['author'] ?? 'Unknown').toString(),
//                 imageUrl: (m['imageUrl'] ?? 'https://orv.pages.dev/assets/covers/orv.webp').toString(),
//                 rating: displayRating,
//                 chapters: chapters,
//                 description: (m['description'] ?? '').toString(),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
