import 'package:flutter/material.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text('No Bookmarks Yet', style: TextStyle(fontSize: 18)),
            SizedBox(height: 5),
            Text('Bookmark your favorite manga to access them quickly', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
