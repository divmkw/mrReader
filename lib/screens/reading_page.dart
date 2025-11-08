import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/manga_fetcher.dart';

class ReaderPage extends StatefulWidget {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final double rating;
  final int chapters;
  final String description;

  const ReaderPage({
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
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late Future<List<Map<String, dynamic>>> _chaptersFuture;
  List<Map<String, dynamic>> _chapters = [];

  int _currentChapterIndex = -1;
  Future<List<String>>? _pagesFuture;

  bool _showControls = true;
  bool _isVerticalScroll = true;
  int _currentPage = 0;

  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _chaptersFuture = MangaDexApi.getChapters(widget.id);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final vertical = prefs.getBool('reader_scroll_mode') ?? true;
    setState(() => _isVerticalScroll = vertical);
  }

  Future<void> _saveScrollPreference(bool vertical) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reader_scroll_mode', vertical);
  }

  void _loadChapterByIndex(int index) {
    if (index < 0 || index >= _chapters.length) return;
    setState(() {
      _currentChapterIndex = index;
      final chapterId = _chapters[index]['id'];
      _pagesFuture = MangaDexApi.getChapterPages(chapterId);
      _currentPage = 0;
    });
  }

  void _nextChapter() {
    if (_currentChapterIndex < _chapters.length - 1) {
      _loadChapterByIndex(_currentChapterIndex + 1);
    }
  }

  void _previousChapter() {
    if (_currentChapterIndex > 0) {
      _loadChapterByIndex(_currentChapterIndex - 1);
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  void _toggleScrollMode() {
    setState(() {
      _isVerticalScroll = !_isVerticalScroll;
      _saveScrollPreference(_isVerticalScroll);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chaptersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load chapters.\n${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No chapters available.', style: TextStyle(color: Colors.white70)),
            );
          }

          _chapters = snapshot.data!;
          return Stack(
            children: [
              // 🔹 Reader Area
              _pagesFuture == null
                  ? const Center(
                      child: Text('Select a chapter to start reading.',
                          style: TextStyle(color: Colors.white70)),
                    )
                  : FutureBuilder<List<String>>(
                      future: _pagesFuture,
                      builder: (context, pageSnap) {
                        if (pageSnap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(color: Colors.white70));
                        } else if (pageSnap.hasError) {
                          return Center(
                            child: Text(
                              'Failed to load pages.\n${pageSnap.error}',
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else if (!pageSnap.hasData || pageSnap.data!.isEmpty) {
                          return const Center(
                            child: Text('No pages found.', style: TextStyle(color: Colors.white70)),
                          );
                        }

                        final pages = pageSnap.data!;

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
                                      width: MediaQuery.of(context).size.width,
                                      placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(
                                              color: Colors.white70)),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.broken_image,
                                              color: Colors.redAccent),
                                    );
                                  },
                                )
                              : PhotoViewGallery.builder(
                                  pageController: _pageController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: pages.length,
                                  builder: (context, index) {
                                    return PhotoViewGalleryPageOptions(
                                      imageProvider:
                                          CachedNetworkImageProvider(pages[index]),
                                      minScale: PhotoViewComputedScale.contained,
                                      maxScale: PhotoViewComputedScale.covered * 3,
                                      heroAttributes:
                                          PhotoViewHeroAttributes(tag: pages[index]),
                                    );
                                  },
                                  backgroundDecoration:
                                      const BoxDecoration(color: Colors.black),
                                  onPageChanged: (index) {
                                    setState(() => _currentPage = index);
                                  },
                                ),
                        );
                      },
                    ),

              // 🔹 Top Controls
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: _showControls ? 0 : -120,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black.withOpacity(0.7),
                    child: Column(
                      children: [
                        // Title
                        if (_currentChapterIndex >= 0)
                          Text(
                            _chapters[_currentChapterIndex]['title'] ?? 'Chapter ${_chapters[_currentChapterIndex]['chapter'] ?? 'N/A'}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 10),

                        // Dropdown
                        DropdownButtonFormField<int>(
                          dropdownColor: Colors.grey[900],
                          value: _currentChapterIndex >= 0 ? _currentChapterIndex : null,
                          hint: const Text('Select Chapter',
                              style: TextStyle(color: Colors.white70)),
                          style: const TextStyle(color: Colors.white),
                          items: _chapters.asMap().entries.map((entry) {
                            final index = entry.key;
                            final chapter = entry.value;
                            final chapterNum = chapter['chapter'] ?? 'N/A';
                            final title = chapter['title'] ?? 'Chapter $chapterNum';
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

              // 🔹 Bottom Controls
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: _showControls ? 0 : -100,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            _currentChapterIndex > 0 ? _previousChapter : null,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text('Prev', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850],
                          disabledBackgroundColor: Colors.grey[700],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _toggleScrollMode,
                        icon: Icon(
                          _isVerticalScroll ? Icons.swap_horiz : Icons.swap_vert,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isVerticalScroll ? 'Horizontal' : 'Vertical',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[800],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _currentChapterIndex < _chapters.length - 1
                            ? _nextChapter
                            : null,
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        label: const Text('Next', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850],
                          disabledBackgroundColor: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔹 Page Indicator (Horizontal mode only)
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
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
}