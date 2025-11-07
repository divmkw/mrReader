// lib/screens/reader_page.dart
import 'package:flutter/material.dart';
import '../bloc/manga_fetcher.dart';

class ReaderPage extends StatefulWidget {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final double rating;
  final int chapters;
  final String description;
  // final String chapterId;
  // final String chapterTitle;

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
  late Future<List<String>> _imageUrls;

  @override
  void initState() {
    super.initState();
    _imageUrls = MangaDexApi.getChapterPages(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<String>>(
        future: _imageUrls,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load chapter.\n${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No pages found.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final pages = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final imageUrl = pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white70),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, color: Colors.redAccent),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
