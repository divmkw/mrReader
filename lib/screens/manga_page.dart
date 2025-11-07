import 'package:flutter/material.dart';
import 'package:mangareader/screens/reading_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class MangaPage extends StatefulWidget {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final double rating;
  final int chapters;
  final String description;

  const MangaPage({
    super.key,
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.rating,
    required this.chapters,
    required this.description,
  });

  @override
  State<MangaPage> createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  int lastRead = 0; // default to 0
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
  }

  Future<void> _loadBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('bookmarks');
    if (raw == null) {
      setState(() => isBookmarked = false);
      return;
    }
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      final exists = list.any((e) {
        final m = e as Map<String, dynamic>;
        return (m['title'] == widget.title) && (m['author'] == widget.author);
      });
      setState(() => isBookmarked = exists);
    } catch (_) {
      setState(() => isBookmarked = false);
    }
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('bookmarks');
    List<dynamic> list;
    try {
      list = raw != null ? (jsonDecode(raw) as List<dynamic>) : <dynamic>[];
    } catch (_) {
      list = <dynamic>[];
    }

    // Remove any existing entry with same title+author
    list = list.where((e) {
      final m = e as Map<String, dynamic>;
      return !(m['title'] == widget.title && m['author'] == widget.author);
    }).toList();

    if (!isBookmarked) {
      list.add({
        'id' :widget.id,
        'title': widget.title,
        'author': widget.author,
        'imageUrl': widget.imageUrl,
        'rating': widget.rating,
        'chapters': widget.chapters,
        'description': widget.description,
        'lastRead': lastRead,
        'savedAt': DateTime.now().toIso8601String(),
      });
    }

    await prefs.setString('bookmarks', jsonEncode(list));
    setState(() => isBookmarked = !isBookmarked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Reader'),
        actions: [
          IconButton(
            tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Manga Title Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Image.network(
                    widget.imageUrl ,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.rating}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.chapters} Chapters',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReaderPage(
                          id: widget.id,
                          title: widget.title,
                          author: widget.author,
                          imageUrl: widget.imageUrl,
                          rating: widget.rating,
                          chapters: widget.chapters,
                          description: widget.description,
                        ),
                      ),
                    );
                    // Continue Reading functionality
                  },
                  child: const Text('Continue Reading'),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Chapters Info
            Row(
              children: [
                Text(
                  'Chapters ($lastRead/${widget.chapters})',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Genres Section
            Wrap(
              spacing: 8.0,
              children: [
                GenreChip(label: 'Action'),
                GenreChip(label: 'Fantasy'),
                GenreChip(label: 'Apocalypse'),
              ],
            ),
            SizedBox(height: 16),

            // Description Section
            Text(
              widget.description.isNotEmpty ? widget.description : 'No description available.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      // background uses theme scaffoldBackgroundColor
    );
  }
}

class GenreChip extends StatelessWidget {
  final String label;

  const GenreChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: scheme.onSecondaryContainer),
      ),
      backgroundColor: scheme.secondaryContainer,
    );
  }
}
