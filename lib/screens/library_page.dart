import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/manga_card.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('bookmarks');
      if (raw == null) {
        setState(() {
          _bookmarks = [];
          _loading = false;
        });
        return;
      }
      final List<dynamic> parsed = jsonDecode(raw) as List<dynamic>;
      final list = parsed.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
      setState(() {
        _bookmarks = list;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _bookmarks = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    if (_bookmarks.isEmpty) {
      return const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
              SizedBox(height: 10),
              Text('No Bookmarks Yet', style: TextStyle(fontSize: 18)),
              SizedBox(height: 5),
              Text('Bookmark your favorite manga to access them quickly', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: RefreshIndicator(
          onRefresh: _loadBookmarks,
          child: GridView.builder(
            itemCount: _bookmarks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 270,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final m = _bookmarks[index];
              final dynamic rawRating = m['rating'];
              final double rating = rawRating is num
                  ? rawRating.toDouble()
                  : (rawRating is String ? double.tryParse(rawRating) ?? 0.0 : 0.0);
              final double displayRating = double.parse(rating.toStringAsFixed(2));

              final dynamic rawCh = m['chapters'];
              final int chapters = rawCh is int
                  ? rawCh
                  : (rawCh is String ? int.tryParse(rawCh) ?? 0 : 0);

              return MangaCard(
                title: (m['title'] ?? 'Unknown').toString(),
                author: (m['author'] ?? 'Unknown').toString(),
                imageUrl: (m['imageUrl'] ?? 'https://via.placeholder.com/256x400?text=No+Cover').toString(),
                rating: displayRating,
                chapters: chapters,
                description: (m['description'] ?? '').toString(),
              );
            },
          ),
        ),
      ),
    );
  }
}
