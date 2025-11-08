import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/manga_fetcher.dart';
import 'reading_page.dart';

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
  late Future<List<Map<String, dynamic>>> _chaptersFuture;
  bool _isBookmarked = false;

  static const String _bookmarkIdsKey = 'bookmarked_manga_ids';
  static const String _bookmarkPrefix = 'bookmark_'; // will store metadata per manga id

  @override
  void initState() {
    super.initState();
    _chaptersFuture = MangaDexApi.getChapters(widget.id);
    _loadBookmarkState();
  }

  Future<void> _loadBookmarkState() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_bookmarkIdsKey) ?? [];
    setState(() {
      _isBookmarked = ids.contains(widget.id);
    });
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_bookmarkIdsKey) ?? [];

    if (_isBookmarked) {
      // remove bookmark
      ids.remove(widget.id);
      await prefs.setStringList(_bookmarkIdsKey, ids);
      await prefs.remove('$_bookmarkPrefix${widget.id}');
      setState(() => _isBookmarked = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from bookmarks')),
      );
    } else {
      // add bookmark
      if (!ids.contains(widget.id)) ids.add(widget.id);
      await prefs.setStringList(_bookmarkIdsKey, ids);

      final meta = {
        'id': widget.id,
        'title': widget.title,
        'author': widget.author,
        'imageUrl': widget.imageUrl,
        'rating': widget.rating,
        'chapters': widget.chapters,
        'description': widget.description,
        'savedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString('$_bookmarkPrefix${widget.id}', jsonEncode(meta));
      setState(() => _isBookmarked = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to bookmarks')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _toggleBookmark,
            icon: _isBookmarked
                ? const Icon(Icons.bookmark, color: Colors.amber)
                : const Icon(Icons.bookmark_border, color: Colors.white),
            tooltip: _isBookmarked ? 'Remove bookmark' : 'Add bookmark',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Cover + Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 180,
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white70),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 180,
                        color: Colors.grey[800],
                        child: const Icon(Icons.broken_image, color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('By ${widget.author}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Rating: ${widget.rating.toStringAsFixed(1)} ⭐',
                            style: const TextStyle(color: Colors.amber)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // 🔹 Description
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(widget.description,
                  style: const TextStyle(color: Colors.white70, height: 1.4)),
            ),

            const Divider(color: Colors.white24),

            // 🔹 Chapter List header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: const Text("Chapters",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),

            // 🔹 Chapters FutureBuilder
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _chaptersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Error loading chapters: ${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent)),
                  ));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('No chapters found.',
                        style: TextStyle(color: Colors.white70)),
                  ));
                }

                final chapters = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: chapters.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    final title = chapter['title'] ?? 'Chapter ${chapter['chapter'] ?? 'N/A'}';
                    final chapterNum = chapter['chapter'] ?? '';

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      title: Text(title, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('Chapter ${chapterNum}', style: const TextStyle(color: Colors.white54)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () {
                        // Open ReaderPage — ReaderPage will fetch chapter pages by itself
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReaderPage(
                              id: widget.id,
                              title: widget.title,
                              author: widget.author,
                              imageUrl: widget.imageUrl,
                              rating: widget.rating,
                              chapters: chapters.length,
                              description: widget.description,
                            ),
                          ),
                        ).then((_) {
                          // optional: you could reload bookmark state if needed
                          _loadBookmarkState();
                        });
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}









// import 'package:flutter/material.dart';
// import 'package:mangareader/screens/reading_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';


// class MangaPage extends StatefulWidget {
//   final String id;
//   final String title;
//   final String author;
//   final String imageUrl;
//   final double rating;
//   final int chapters;
//   final String description;

//   const MangaPage({
//     super.key,
//     required this.id,
//     required this.title,
//     required this.author,
//     required this.imageUrl,
//     required this.rating,
//     required this.chapters,
//     required this.description,
//   });

//   @override
//   State<MangaPage> createState() => _MangaPageState();
// }

// class _MangaPageState extends State<MangaPage> {
//   int lastRead = 0; // default to 0
//   bool isBookmarked = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadBookmarkStatus();
//   }

//   Future<void> _loadBookmarkStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString('bookmarks');
//     if (raw == null) {
//       setState(() => isBookmarked = false);
//       return;
//     }
//     try {
//       final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
//       final exists = list.any((e) {
//         final m = e as Map<String, dynamic>;
//         return (m['title'] == widget.title) && (m['author'] == widget.author);
//       });
//       setState(() => isBookmarked = exists);
//     } catch (_) {
//       setState(() => isBookmarked = false);
//     }
//   }

//   Future<void> _toggleBookmark() async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString('bookmarks');
//     List<dynamic> list;
//     try {
//       list = raw != null ? (jsonDecode(raw) as List<dynamic>) : <dynamic>[];
//     } catch (_) {
//       list = <dynamic>[];
//     }

//     // Remove any existing entry with same title+author
//     list = list.where((e) {
//       final m = e as Map<String, dynamic>;
//       return !(m['title'] == widget.title && m['author'] == widget.author);
//     }).toList();

//     if (!isBookmarked) {
//       list.add({
//         'id' :widget.id,
//         'title': widget.title,
//         'author': widget.author,
//         'imageUrl': widget.imageUrl,
//         'rating': widget.rating,
//         'chapters': widget.chapters,
//         'description': widget.description,
//         'lastRead': lastRead,
//         'savedAt': DateTime.now().toIso8601String(),
//       });
//     }

//     await prefs.setString('bookmarks', jsonEncode(list));
//     setState(() => isBookmarked = !isBookmarked);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manga Reader'),
//         actions: [
//           IconButton(
//             tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
//             icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
//             onPressed: _toggleBookmark,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             // Manga Title Section
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.all(Radius.circular(12)),
//                   child: Image.network(
//                     widget.imageUrl ,
//                     width: 100,
//                     height: 150,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.title,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         widget.author,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.star, color: Colors.amber, size: 20),
//                           const SizedBox(width: 4),
//                           Text(
//                             '${widget.rating}',
//                             style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${widget.chapters} Chapters',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
            
//             // Action Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ReaderPage(
//                           id: widget.id,
//                           title: widget.title,
//                           author: widget.author,
//                           imageUrl: widget.imageUrl,
//                           rating: widget.rating,
//                           chapters: widget.chapters,
//                           description: widget.description,
//                         ),
//                       ),
//                     );
//                     // Continue Reading functionality
//                   },
//                   child: const Text('Continue Reading'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
            
//             // Chapters Info
//             Row(
//               children: [
//                 Text(
//                   'Chapters ($lastRead/${widget.chapters})',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
            
//             // Genres Section
//             Wrap(
//               spacing: 8.0,
//               children: [
//                 GenreChip(label: 'Action'),
//                 GenreChip(label: 'Fantasy'),
//                 GenreChip(label: 'Apocalypse'),
//               ],
//             ),
//             SizedBox(height: 16),

//             // Description Section
//             Text(
//               widget.description.isNotEmpty ? widget.description : 'No description available.',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//           ],
//         ),
//       ),
//       // background uses theme scaffoldBackgroundColor
//     );
//   }
// }

// class GenreChip extends StatelessWidget {
//   final String label;

//   const GenreChip({super.key, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     return Chip(
//       label: Text(
//         label,
//         style: TextStyle(color: scheme.onSecondaryContainer),
//       ),
//       backgroundColor: scheme.secondaryContainer,
//     );
//   }
// }
