import 'package:flutter/material.dart';
import '../widgets/manga_card.dart';
import '../bloc/manga_fecher.dart';
import 'dart:async';
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _results = [];
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      if (query.trim().isEmpty) {
        setState(() {
          _results.clear();
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        final list = await MangaDexApi.searchManga(query, limit: 20);
        if (!mounted) return;
        setState(() {
          _results
            ..clear()
            ..addAll(list);
          _isLoading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _results.clear();
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Search manga, manhwa, authors...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: GridView.builder(
                itemCount: _results.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 270,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final manga = _results[index];
                  final dynamic rawRating = manga['rating'];
                  final double safeRating = rawRating is num
                      ? rawRating.toDouble()
                      : (rawRating is String ? double.tryParse(rawRating) ?? 0.0 : 0.0);
                  final double displayRating = double.parse(safeRating.toStringAsFixed(2));

                  final dynamic rawCh = manga['chapters'];
                  final int safeChapters = rawCh is int
                      ? rawCh
                      : (rawCh is String ? int.tryParse(rawCh) ?? 0 : 0);

                  return MangaCard(
                    title: manga['title'] as String? ?? 'Unknown',
                    author: manga['author'] as String? ?? 'Unknown',
                    imageUrl: manga['coverUrl'] as String? ?? 'https://via.placeholder.com/256x400?text=No+Cover',
                    rating: displayRating,
                    chapters: safeChapters,
                    description: manga['description'] as String? ?? '',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
