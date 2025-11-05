import 'package:flutter/material.dart';
import '../widgets/manga_card.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mangaList = [
      {
        'title': 'Omniscient Reader',
        'author': 'Sing Shong',
        'image': 'https://orv.pages.dev/assets/covers/orv.webp',
        'rating': 9.3,
        'chapters': 151
      },
      {
        'title': 'Solo Leveling',
        'author': 'Chugong',
        'image': 'https://i.imgur.com/2p2F2dO.jpeg',
        'rating': 9.2,
        'chapters': 179
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextField(
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
            Expanded(
              child: GridView.builder(
                itemCount: mangaList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 270,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final manga = mangaList[index];
                  return MangaCard(
                    title: manga['title']! as String,
                    author: manga['author']! as String,
                    imageUrl: manga['image']! as String,
                    rating: manga['rating']! as double,
                    chapters: manga['chapters']! as int,
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
