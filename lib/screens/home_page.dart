import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/manga_card.dart';
import '../providers/manga_provider.dart';
import 'notification_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaAsync = ref.watch(trendingMangaProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(trendingMangaProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Top bar
              Row(
                children: [
                  const Icon(Icons.menu, size: 28),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Trending section header
              Row(
                children: [
                  const Icon(Icons.trending_up),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Trending Now',
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Trending manga list
              SizedBox(
                height: 270,
                child: mangaAsync.when(
                  data: (mangaList) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mangaList.length,
                    itemBuilder: (context, index) {
                      final manga = mangaList[index];
                      final double rating = _twoDecimal(_safeDouble(manga['rating']));
                      final int chapters = _safeInt(manga['chapters']);

                      return SizedBox(
                        width: 160, // Prevent overflow in horizontal list
                        child: MangaCard(
                          id: (manga['id'] ?? '0').toString(),
                          title: (manga['title'] ?? 'Unknown').toString(),
                          author: (manga['author'] ?? 'Unknown').toString(),
                          imageUrl: (manga['coverUrl'] ??
                                  'https://orv.pages.dev/assets/covers/orv.webp')
                              .toString(),
                          rating: rating,
                          chapters: chapters,
                          description: (manga['description'] ?? '').toString(),
                        ),
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load: $err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => ref.refresh(trendingMangaProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Top rated section
              Text('Top Rated', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),

              SizedBox(
                height: 270,
                child: mangaAsync.when(
                  data: (mangaList) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mangaList.length,
                    itemBuilder: (context, index) {
                      final manga = mangaList[index];
                      final double rating = _twoDecimal(_safeDouble(manga['rating']));
                      final int chapters = _safeInt(manga['chapters']);

                      return SizedBox(
                        width: 160,
                        child: MangaCard(
                          id: (manga['id'] ?? '0').toString(),
                          title: (manga['title'] ?? 'Unknown').toString(),
                          author: (manga['author'] ?? 'Unknown').toString(),
                          imageUrl: (manga['coverUrl'] ??
                                  'https://via.placeholder.com/256x400?text=No+Cover')
                              .toString(),
                          rating: rating,
                          chapters: chapters,
                          description: (manga['description'] ?? '').toString(),
                        ),
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ensures number is parsed safely as double
  double _safeDouble(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0.0;

  /// Ensures number is parsed safely as int
  int _safeInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  /// Formats to 2 decimal places safely
  double _twoDecimal(double value) =>
      double.parse(value.toStringAsFixed(2));
}