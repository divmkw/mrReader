import 'package:flutter/material.dart';
import '../widgets/manga_card.dart';
// import 'notificaiton_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        'image': 'https://mangadex.org/covers/32d76d19-8a05-4db0-9fc2-e0b0648fe9d0/e90bdc47-c8b9-4df7-b2c0-17641b645ee1.jpg',
        'rating': 9.2,
        'chapters': 179
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            // Row(children: [
            //   Icon(Icons.menu, size: 28),
            //   Spacer(),
            //   IconButton(
            //     icon: Icon(Icons.notifications_none, size: 28),
            //     onPressed: () {
            //       // Handle notification button press
            //     },
            //   ),
            // ]),
            Row(children: [
              Icon(Icons.menu, size: 28),
              Spacer(),
              IconButton(
                icon: Icon(Icons.notifications_none, size: 28),
                onPressed: () {
                  // Handle notification button press
                },
              ),
              Icon(Icons.trending_up),
              const SizedBox(height: 10),
              Text('Trending Now', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 15),
            ]),
            SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mangaList.length,
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
            const SizedBox(height: 20),
            Text('Top Rated', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mangaList.length,
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
