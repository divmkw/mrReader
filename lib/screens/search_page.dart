// lib/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import '../providers/search_history_provider.dart';
import '../widgets/manga_card.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(searchProvider);
    final history = ref.watch(searchHistoryProvider);
    final controller = TextEditingController();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Search Bar
            TextField(
              controller: controller,
              // onChanged: (q) => ref.read(searchProvider.notifier).search(q),
              onSubmitted: (q) {
                ref.read(searchHistoryProvider.notifier).add(q);
                ref.read(searchProvider.notifier).search(q);
              },
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

            // Recent Searches
            if (controller.text.isEmpty)
              history.when(
                data: (historyList) {
                  if (historyList.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Searches',
                              style: Theme.of(context).textTheme.titleMedium),
                          TextButton(
                            onPressed: () =>
                                ref.read(searchHistoryProvider.notifier).clear(),
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: historyList.length,
                          itemBuilder: (context, index) {
                            final item = historyList[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(item),
                                onPressed: () {
                                  controller.text = item;
                                  ref
                                      .read(searchProvider.notifier)
                                      .search(item);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

            // Results
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: searchAsync.when(
                  data: (results) {
                    if (results.isEmpty) {
                      return const Center(
                          child: Text('No results found. Try another query.'));
                    }
                    return GridView.builder(
                      itemCount: results.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 270,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final manga = results[index];
                        final double rating = _safeDouble(manga['rating']);
                        final int chapters = _safeInt(manga['chapters']);

                        return MangaCard(
                          id: (manga['id'] ?? '0').toString(),
                          title: (manga['title'] ?? 'Unknown').toString(),
                          author: (manga['author'] ?? 'Unknown').toString(),
                          imageUrl: (manga['coverUrl'] ??
                                  'https://via.placeholder.com/256x400?text=No+Cover')
                              .toString(),
                          rating: rating,
                          chapters: chapters,
                          description: (manga['description'] ?? '').toString(),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Text('Error: $err'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _safeDouble(dynamic value) =>
      value is num ? double.parse(value.toStringAsFixed(2)) : 0.0;

  int _safeInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}