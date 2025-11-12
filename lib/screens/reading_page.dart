import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../bloc/manga_fetcher.dart';
import '../providers/manga_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderPage extends ConsumerStatefulWidget {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final double rating;
  final int chapters;
  final String description;
  final int initialChapterIndex;

  const ReaderPage({
    super.key,
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.rating,
    required this.chapters,
    required this.description,
    required this.initialChapterIndex,
  });

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  late int _currentChapterIndex;
  Future<List<String>>? _pagesFuture;

  bool _showControls = true;
  bool _isVerticalScroll = true;
  int _currentPage = 0;

  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentChapterIndex = widget.initialChapterIndex;
    _loadPreferences();
    _loadChapterByIndex(_currentChapterIndex);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isVerticalScroll = prefs.getBool('reader_scroll_mode') ?? true);
  }

  Future<void> _saveScrollPreference(bool vertical) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reader_scroll_mode', vertical);
  }

  void _loadChapterByIndex(int index) async {
    final chaptersAsync = await ref.read(chaptersProvider(widget.id).future);
    if (index < 0 || index >= chaptersAsync.length) return;

    setState(() {
      _currentChapterIndex = index;
      _pagesFuture = MangaDexApi.getChapterPages(chaptersAsync[index]['id']);
      _currentPage = 0;
    });

    // Persist last read chapter index
    await ref.read(lastReadProvider(widget.id)).updateLastRead(index);
  }

  void _nextChapter() {
    _loadChapterByIndex(_currentChapterIndex + 1);
  }

  void _previousChapter() {
    _loadChapterByIndex(_currentChapterIndex - 1);
  }

  void _toggleControls() => setState(() => _showControls = !_showControls);

  void _toggleScrollMode() {
    setState(() {
      _isVerticalScroll = !_isVerticalScroll;
      _saveScrollPreference(_isVerticalScroll);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider(widget.id));

    return Scaffold(
      backgroundColor: Colors.black,
      body: chaptersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, _) => Center(
          child: Text(
            'Failed to load chapters.\n$err',
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
        data: (chapters) {
          return Stack(
            children: [
              // Reader
              _pagesFuture == null
                  ? const Center(
                      child: Text(
                        'Loading chapter...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : FutureBuilder<List<String>>(
                      future: _pagesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(color: Colors.white70));
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Failed to load pages.\n${snapshot.error}',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No pages found.', style: TextStyle(color: Colors.white70)));
                        }

                        final pages = snapshot.data!;
                        return GestureDetector(
                          onTap: _toggleControls,
                          child: _isVerticalScroll
                              ? ListView.builder(
                                  controller: _scrollController,
                                  itemCount: pages.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    return CachedNetworkImage(
                                      imageUrl: pages[index],
                                      fit: BoxFit.fitWidth,
                                      placeholder: (_, __) => const Center(
                                          child: CircularProgressIndicator(color: Colors.white70)),
                                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.redAccent),
                                    );
                                  },
                                )
                              : PhotoViewGallery.builder(
                                  pageController: _pageController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: pages.length,
                                  builder: (context, index) {
                                    return PhotoViewGalleryPageOptions(
                                      imageProvider: CachedNetworkImageProvider(pages[index]),
                                      minScale: PhotoViewComputedScale.contained,
                                      maxScale: PhotoViewComputedScale.covered * 3,
                                    );
                                  },
                                  onPageChanged: (index) => setState(() => _currentPage = index),
                                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                                ),
                        );
                      },
                    ),

              // Top Controls
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: _showControls ? 0 : -140,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black.withValues(alpha: 0.6),
                    child: Column(
                      children: [
                        Text(
                          chapters[_currentChapterIndex]['title'] ??
                              'Chapter ${chapters[_currentChapterIndex]['chapter'] ?? 'N/A'}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          dropdownColor: Colors.grey[900],
                          value: _currentChapterIndex,
                          iconEnabledColor: Colors.white70,
                          style: const TextStyle(color: Colors.white),
                          items: chapters.asMap().entries.map((e) {
                            final index = e.key;
                            final chapter = e.value;
                            final title = chapter['title'] ?? 'Chapter ${chapter['chapter'] ?? 'N/A'}';
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Text(title, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (index) {
                            if (index != null) _loadChapterByIndex(index);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Controls
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: _showControls ? 0 : -100,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(Icons.arrow_back, 'Prev', _previousChapter,
                          enabled: _currentChapterIndex > 0),
                      _buildButton(
                        _isVerticalScroll ? Icons.swap_horiz : Icons.swap_vert,
                        _isVerticalScroll ? 'Horizontal' : 'Vertical',
                        _toggleScrollMode,
                        color: Colors.blueGrey[700],
                      ),
                      _buildButton(Icons.arrow_forward, 'Next', _nextChapter,
                          enabled: _currentChapterIndex < chapters.length - 1),
                    ],
                  ),
                ),
              ),

              // Page Indicator (Horizontal only)
              if (_pagesFuture != null && !_isVerticalScroll)
                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _showControls ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Page ${_currentPage + 1}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButton(IconData icon, String text, VoidCallback onPressed,
      {bool enabled = true, Color? color}) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? (color ?? Colors.grey[850]) : Colors.grey[700],
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../bloc/manga_fetcher.dart';

// class ReaderPage extends StatefulWidget {
//   final String id;
//   final String title;
//   final String author;
//   final String imageUrl;
//   final double rating;
//   final int chapters;
//   final String description;
//   final String chapterIndex;

//   const ReaderPage({
//     super.key,
//     required this.id,
//     required this.title,
//     required this.author,
//     required this.imageUrl,
//     required this.rating,
//     required this.chapters,
//     required this.description,
//     required this.chapterIndex,
//   });

//   @override
//   State<ReaderPage> createState() => _ReaderPageState();
// }

// class _ReaderPageState extends State<ReaderPage> {
//   late Future<List<Map<String, dynamic>>> _chaptersFuture;
//   List<Map<String, dynamic>> _chapters = [];

//   int _currentChapterIndex = -1;
//   Future<List<String>>? _pagesFuture;

//   bool _showControls = true;
//   bool _isVerticalScroll = true;
//   int _currentPage = 0;

//   final PageController _pageController = PageController();
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _loadPreferences();
//     _chaptersFuture = MangaDexApi.getChapters(widget.id);
//   }

//   Future<void> _loadPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     final vertical = prefs.getBool('reader_scroll_mode') ?? true;
//     setState(() => _isVerticalScroll = vertical);
//   }

//   Future<void> _saveScrollPreference(bool vertical) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('reader_scroll_mode', vertical);
//   }

//   void _loadChapterByIndex(int index) {
//     if (index < 0 || index >= _chapters.length) return;
//     setState(() {
//       _currentChapterIndex = index;
//       final chapterId = _chapters[index]['id'];
//       _pagesFuture = MangaDexApi.getChapterPages(chapterId);
//       _currentPage = 0;
//     });
//   }

//   void _nextChapter() {
//     if (_currentChapterIndex < _chapters.length - 1) {
//       _loadChapterByIndex(_currentChapterIndex + 1);
//     }
//   }

//   void _previousChapter() {
//     if (_currentChapterIndex > 0) {
//       _loadChapterByIndex(_currentChapterIndex - 1);
//     }
//   }

//   void _toggleControls() {
//     setState(() => _showControls = !_showControls);
//   }

//   void _toggleScrollMode() {
//     setState(() {
//       _isVerticalScroll = !_isVerticalScroll;
//       _saveScrollPreference(_isVerticalScroll);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _chaptersFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator(color: Colors.white));
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Failed to load chapters.\n${snapshot.error}',
//                 style: const TextStyle(color: Colors.redAccent),
//                 textAlign: TextAlign.center,
//               ),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text('No chapters available.', style: TextStyle(color: Colors.white70)),
//             );
//           }

//           _chapters = snapshot.data!;
//           return Stack(
//             children: [
//               // 🔹 Reader Area
//               _pagesFuture == null
//                   ? const Center(
//                       child: Text('Select a chapter to start reading.',
//                           style: TextStyle(color: Colors.white70)),
//                     )
//                   : FutureBuilder<List<String>>(
//                       future: _pagesFuture,
//                       builder: (context, pageSnap) {
//                         if (pageSnap.connectionState == ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator(color: Colors.white70));
//                         } else if (pageSnap.hasError) {
//                           return Center(
//                             child: Text(
//                               'Failed to load pages.\n${pageSnap.error}',
//                               style: const TextStyle(color: Colors.redAccent),
//                               textAlign: TextAlign.center,
//                             ),
//                           );
//                         } else if (!pageSnap.hasData || pageSnap.data!.isEmpty) {
//                           return const Center(
//                             child: Text('No pages found.', style: TextStyle(color: Colors.white70)),
//                           );
//                         }

//                         final pages = pageSnap.data!;

//                         return GestureDetector(
//                           onTap: _toggleControls,
//                           child: _isVerticalScroll
//                               ? ListView.builder(
//                                   controller: _scrollController,
//                                   itemCount: pages.length,
//                                   padding: EdgeInsets.zero,
//                                   itemBuilder: (context, index) {
//                                     return CachedNetworkImage(
//                                       imageUrl: pages[index],
//                                       fit: BoxFit.fitWidth,
//                                       width: MediaQuery.of(context).size.width,
//                                       placeholder: (context, url) => const Center(
//                                           child: CircularProgressIndicator(
//                                               color: Colors.white70)),
//                                       errorWidget: (context, url, error) =>
//                                           const Icon(Icons.broken_image,
//                                               color: Colors.redAccent),
//                                     );
//                                   },
//                                 )
//                               : PhotoViewGallery.builder(
//                                   pageController: _pageController,
//                                   scrollDirection: Axis.horizontal,
//                                   itemCount: pages.length,
//                                   builder: (context, index) {
//                                     return PhotoViewGalleryPageOptions(
//                                       imageProvider:
//                                           CachedNetworkImageProvider(pages[index]),
//                                       minScale: PhotoViewComputedScale.contained,
//                                       maxScale: PhotoViewComputedScale.covered * 3,
//                                       heroAttributes:
//                                           PhotoViewHeroAttributes(tag: pages[index]),
//                                     );
//                                   },
//                                   backgroundDecoration:
//                                       const BoxDecoration(color: Colors.black),
//                                   onPageChanged: (index) {
//                                     setState(() => _currentPage = index);
//                                   },
//                                 ),
//                         );
//                       },
//                     ),

//               // 🔹 Top Controls
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 300),
//                 top: _showControls ? 0 : -120,
//                 left: 0,
//                 right: 0,
//                 child: SafeArea(
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     color: Colors.black.withValues(alpha: 0.7),
//                     child: Column(
//                       children: [
//                         // Title
//                         if (_currentChapterIndex >= 0)
//                           Text(
//                             _chapters[_currentChapterIndex]['title'] ?? 'Chapter ${_chapters[_currentChapterIndex]['chapter'] ?? 'N/A'}',
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         const SizedBox(height: 10),

//                         // Dropdown
//                         DropdownButtonFormField<int>(
//                           dropdownColor: Colors.grey[900],
//                           initialValue: _currentChapterIndex >= 0 ? _currentChapterIndex : null,
//                           hint: const Text('Select Chapter',
//                               style: TextStyle(color: Colors.white70)),
//                           style: const TextStyle(color: Colors.white),
//                           items: _chapters.asMap().entries.map((entry) {
//                             final index = entry.key;
//                             final chapter = entry.value;
//                             final chapterNum = chapter['chapter'] ?? 'N/A';
//                             final title = chapter['title'] ?? 'Chapter $chapterNum';
//                             return DropdownMenuItem<int>(
//                               value: index,
//                               child: Text(title, overflow: TextOverflow.ellipsis),
//                             );
//                           }).toList(),
//                           onChanged: (index) {
//                             if (index != null) _loadChapterByIndex(index);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               // 🔹 Bottom Controls
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 300),
//                 bottom: _showControls ? 0 : -100,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   color: Colors.black.withValues(alpha: 0.7),
//                   padding: const EdgeInsets.all(10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed:
//                             _currentChapterIndex > 0 ? _previousChapter : null,
//                         icon: const Icon(Icons.arrow_back, color: Colors.white),
//                         label: const Text('Prev', style: TextStyle(color: Colors.white)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey[850],
//                           disabledBackgroundColor: Colors.grey[700],
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: _toggleScrollMode,
//                         icon: Icon(
//                           _isVerticalScroll ? Icons.swap_horiz : Icons.swap_vert,
//                           color: Colors.white,
//                         ),
//                         label: Text(
//                           _isVerticalScroll ? 'Horizontal' : 'Vertical',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueGrey[800],
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: _currentChapterIndex < _chapters.length - 1
//                             ? _nextChapter
//                             : null,
//                         icon: const Icon(Icons.arrow_forward, color: Colors.white),
//                         label: const Text('Next', style: TextStyle(color: Colors.white)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey[850],
//                           disabledBackgroundColor: Colors.grey[700],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // 🔹 Page Indicator (Horizontal mode only)
//               if (_pagesFuture != null && !_isVerticalScroll)
//                 Positioned(
//                   bottom: 120,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: AnimatedOpacity(
//                       opacity: _showControls ? 1 : 0,
//                       duration: const Duration(milliseconds: 300),
//                       child: Container(
//                         padding:
//                             const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withValues(alpha: 0.6),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           'Page ${_currentPage + 1}',
//                           style: const TextStyle(color: Colors.white70),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }