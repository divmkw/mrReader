import 'package:flutter/material.dart';
import '../widgets/manga_card.dart';
// import 'notificaiton_page.dart';
import '../bloc/manga_fecher.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _mangaList = [];
  String? _error;

  @override
  void initState() {
      super.initState();
      loadManga();
  }

  Future<void> loadManga() async {
    try {
      final mangaList = await MangaDexApi.getTrendingManga();
      setState(() {
        _error = null;
        _mangaList = mangaList;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _mangaList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rendering uses `_mangaList` loaded in initState
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
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
            SizedBox (
              height: 270,
              child: _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Failed to load: ${_error}', textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          ElevatedButton(onPressed: loadManga, child: const Text('Retry')),
                        ],
                      ),
                    )
                  : _mangaList.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mangaList.length,
                      itemBuilder: (context, index) {
                        final manga = _mangaList[index];
                        return MangaCard(
                          title: (manga['title'] ?? 'Unknown') as String,
                          author: (manga['author'] ?? 'Unknown') as String,
                          imageUrl: (manga['coverUrl'] ?? 'https://orv.pages.dev/assets/covers/orv.webp') as String,
                          rating: 0.0,
                          chapters: 0,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Text('Top Rated', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            SizedBox(
              height: 270,
              child: _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Failed to load: ${_error}', textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          ElevatedButton(onPressed: loadManga, child: const Text('Retry')),
                        ],
                      ),
                    )
                  : _mangaList.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mangaList.length,
                      itemBuilder: (context, index) {
                        final manga = _mangaList[index];
                        return MangaCard(
                          title: (manga['title'] ?? 'Unknown') as String,
                          author: 'Unknown',
                          imageUrl: (manga['coverUrl'] ?? 'https://via.placeholder.com/256x400?text=No+Cover') as String,
                          rating: 0.0,
                          chapters: 0,
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
