import 'package:flutter/material.dart';


class MangaPage extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final double rating;
  final int chapters;

  const MangaPage({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.rating,
    required this.chapters,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Reader'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Manga Title Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Image.network(
                    imageUrl ,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$rating',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$chapters Chapters',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // ElevatedButton(
                //   onPressed: () {
                //     // Navigate to Tappytoon
                //   },
                //   style: ElevatedButton.styleFrom(
                //     // primary: Colors.blueAccent,
                //     // onPrimary: Colors.white,
                //   ),
                //   child: Row(
                //     children: [
                //       Icon(Icons.link, size: 10),
                //       SizedBox(width: 3),
                //       Text('Read on Tappytoon'),
                //     ],
                //   ),
                // ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Continue Reading functionality
                  },
                  child: const Text('Continue Reading'),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Chapters Info
            Row(
              children: [
                Text(
                  'Chapters (1/151)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Genres Section
            Wrap(
              spacing: 8.0,
              children: [
                GenreChip(label: 'Action'),
                GenreChip(label: 'Fantasy'),
                GenreChip(label: 'Apocalypse'),
              ],
            ),
            SizedBox(height: 16),

            // Description Section
            Text(
              'The only reader of a web novel witnesses it coming to life. Using his knowledge, he must survive the apocalyptic scenario.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      // background uses theme scaffoldBackgroundColor
    );
  }
}

class GenreChip extends StatelessWidget {
  final String label;

  GenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: scheme.onSecondaryContainer),
      ),
      backgroundColor: scheme.secondaryContainer,
    );
  }
}
