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
        title: Text('Manga Reader'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Manga Title Section
            Row(
              children: [
                Image.network(
                  imageUrl ?? 'https://orv.pages.dev/assets/covers/orv.webp',
                  width: 100,
                  height: 150,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      author,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '$rating',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$chapters Chapters',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
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
                  child: Text('Continue Reading'),
                  style: ElevatedButton.styleFrom(
                    // primary: Colors.green,
                    // onPrimary: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Chapters Info
            Row(
              children: [
                Text(
                  'Chapters (1/151)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}

class GenreChip extends StatelessWidget {
  final String label;

  GenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blueGrey,
    );
  }
}
