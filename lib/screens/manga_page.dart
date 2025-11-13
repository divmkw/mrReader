import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Mr.reader/providers/manga_provider.dart';
import 'reading_page.dart';

class MangaPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider(id));
    // final isBookmarked = ref.watch(bookmarkProvider(id));
    final bookmarkNotifier = ref.watch(bookmarkProvider(id));
    final isBookmarked = bookmarkNotifier.isBookmarked;


    final lastRead = ref.watch(lastReadProvider(id));

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.amber : Colors.white,
            ),
            onPressed: () {
              ref.read(bookmarkProvider(id)).toggleBookmark({
                'id': id,
                'title': title,
                'author': author,
                'imageUrl': imageUrl,
                'rating': rating,
                'chapters': chapters,
                'description': description,
              });
              // ref.read(bookmarkProvider(id))._load();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 120,
                        height: 180,
                        color: Colors.grey[800],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('By $author',
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text('Rating: ${rating.toStringAsFixed(1)} ⭐',
                            style: const TextStyle(color: Colors.amber)),
                        const SizedBox(height: 10),
                        if (lastRead.lastReadIndex > 0)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReaderPage(
                                    id: id,
                                    title: title,
                                    author: author,
                                    imageUrl: imageUrl,
                                    rating: rating,
                                    chapters: chapters,
                                    description: description,
                                    initialChapterIndex: lastRead.lastReadIndex,
                                    // chapterIndex: lastRead.toString(),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text("Resume Reading"),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(description,
                  style: const TextStyle(color: Colors.white70, height: 1.4)),
            ),

            const Divider(color: Colors.white24),

            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Chapters",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),

            chaptersAsync.when(
              data: (chapters) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  final title = chapter['title'] ?? 'Chapter ${chapter['chapter'] ?? 'N/A'}';

                  return ListTile(
                    title: Text(title, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('Chapter ${chapter['chapter'] ?? ''}',
                        style: const TextStyle(color: Colors.white54)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                    onTap: () async {
                      // update last read
                      await ref.read(lastReadProvider(id)).updateLastRead(index); // update last read

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderPage(
                            id: id,
                            title: title,
                            author: author,
                            imageUrl: imageUrl,
                            rating: rating,
                            chapters: chapters.length,
                            description: description,
                            initialChapterIndex: index,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../bloc/manga_fetcher.dart';
// import 'reading_page.dart';

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
//   late Future<List<Map<String, dynamic>>> _chaptersFuture;
//   bool _isBookmarked = false;
//   int lastRead = 0; // default to 0

//   // static const String _bookmarkIdsKey = 'bookmarked_manga_ids';
//   // static const String _bookmarkPrefix = 'bookmark_'; // will store metadata per manga id

//   @override
//   void initState() {
//     super.initState();
//     _chaptersFuture = MangaDexApi.getChapters(widget.id);
//     _loadBookmarkStatus();
//   }

//   Future<void> _loadBookmarkStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString('bookmarks');
//     if (raw == null) {
//       setState(() => _isBookmarked = false);
//       return;
//     }
//     try {
//       final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
//       final exists = list.any((e) {
//         final m = e as Map<String, dynamic>;
//         return (m['title'] == widget.title) && (m['author'] == widget.author);
//       });
//       setState(() => _isBookmarked = exists);
//     } catch (_) {
//       setState(() => _isBookmarked = false);
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

//     if (!_isBookmarked) {
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
//     setState(() => _isBookmarked = !_isBookmarked);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[900],
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Text(widget.title, style: const TextStyle(color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             onPressed: _toggleBookmark,
//             icon: _isBookmarked
//                 ? const Icon(Icons.bookmark, color: Colors.amber)
//                 : const Icon(Icons.bookmark_border, color: Colors.white),
//             tooltip: _isBookmarked ? 'Remove bookmark' : 'Add bookmark',
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🔹 Cover + Info
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: CachedNetworkImage(
//                       imageUrl: widget.imageUrl,
//                       width: 120,
//                       height: 180,
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) => Container(
//                         width: 120,
//                         height: 180,
//                         color: Colors.grey[800],
//                         child: const Center(
//                           child: CircularProgressIndicator(color: Colors.white70),
//                         ),
//                       ),
//                       errorWidget: (context, url, error) => Container(
//                         width: 120,
//                         height: 180,
//                         color: Colors.grey[800],
//                         child: const Icon(Icons.broken_image, color: Colors.redAccent),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(widget.title,
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 4),
//                         Text('By ${widget.author}',
//                             style: const TextStyle(
//                                 color: Colors.white70, fontSize: 14)),
//                         const SizedBox(height: 4),
//                         Text('Rating: ${widget.rating.toStringAsFixed(1)} ⭐',
//                             style: const TextStyle(color: Colors.amber)),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),

//             // 🔹 Description
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Text(widget.description,
//                   style: const TextStyle(color: Colors.white70, height: 1.4)),
//             ),

//             const Divider(color: Colors.white24),

//             // 🔹 Chapter List header
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//               child: const Text("Chapters",
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18)),
//             ),

//             // 🔹 Chapters FutureBuilder
//             FutureBuilder<List<Map<String, dynamic>>>(
//               future: _chaptersFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                       child: Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: CircularProgressIndicator(color: Colors.white),
//                   ));
//                 } else if (snapshot.hasError) {
//                   return Center(
//                       child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Text('Error loading chapters: ${snapshot.error}',
//                         style: const TextStyle(color: Colors.redAccent)),
//                   ));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(
//                       child: Padding(
//                     padding: EdgeInsets.all(12.0),
//                     child: Text('No chapters found.',
//                         style: TextStyle(color: Colors.white70)),
//                   ));
//                 }

//                 final chapters = snapshot.data!;
//                 return ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: chapters.length,
//                   separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
//                   itemBuilder: (context, index) {
//                     final chapter = chapters[index];
//                     final title = chapter['title'] ?? 'Chapter ${chapter['chapter'] ?? 'N/A'}';
//                     final chapterNum = chapter['chapter'] ?? '';

//                     return ListTile(
//                       dense: true,
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                       title: Text(title, style: const TextStyle(color: Colors.white)),
//                       subtitle: Text('Chapter $chapterNum', style: const TextStyle(color: Colors.white54)),
//                       trailing: const Icon(Icons.chevron_right, color: Colors.white54),
//                       onTap: () {
//                         // Open ReaderPage — ReaderPage will fetch chapter pages by itself
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ReaderPage(
//                               id: widget.id,
//                               title: widget.title,
//                               author: widget.author,
//                               imageUrl: widget.imageUrl,
//                               rating: widget.rating,
//                               chapters: chapters.length,
//                               description: widget.description,
//                             ),
//                           ),
//                         ).then((_) {
//                           // optional: you could reload bookmark state if needed
//                           _loadBookmarkStatus();
//                         });
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }