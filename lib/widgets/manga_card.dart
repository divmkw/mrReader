import 'package:flutter/material.dart';
import '../screens/manga_page.dart';

class MangaCard extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final double rating;
  final int chapters;

  const MangaCard({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.rating,
    required this.chapters,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaPage(
              title: title,
              author: author,
              imageUrl: imageUrl,
              rating: rating,
              chapters: chapters,
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(author, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('$rating', style: const TextStyle(fontSize: 12)),
                const Spacer(),
                Text('$chapters Ch', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }
}
