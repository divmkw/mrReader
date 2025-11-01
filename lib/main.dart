// main.dart
// Manga Reader — UI converted from Figma link
// Single-file Flutter app demonstrating a modern manga reader home UI.

import 'package:flutter/material.dart';

void main() => runApp(MangaReaderApp());

class MangaReaderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Color(0xFFF6F6F9),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _search = '';

  final List<Map<String, String>> featured = List.generate(
    6,
    (i) => {
      'title': 'Manga Title ${i + 1}',
      'author': 'Author ${i + 1}',
      'image': 'https://picsum.photos/200/300?random=${i + 10}'
    },
  );

  final List<Map<String, String>> updates = List.generate(
    8,
    (i) => {
      'title': 'Chapter ${i + 1}',
      'manga': 'Manga ${i + 1}',
      'image': 'https://picsum.photos/300/200?random=${i + 30}'
    },
  );

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  NetworkImage('https://picsum.photos/seed/profile/100'),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning,',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                Text('Reader',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_none)),
          SizedBox(width: 8)
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              SizedBox(height: 18),
              _buildCategoryChips(),
              SizedBox(height: 18),
              Text('Featured', style: _sectionTitleStyle()),
              SizedBox(height: 12),
              _buildFeaturedCarousel(width),
              SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Latest Updates', style: _sectionTitleStyle()),
                  TextButton(
                    onPressed: () {},
                    child: Text('See all', style: TextStyle(color: Colors.deepPurple)),
                  )
                ],
              ),
              SizedBox(height: 8),
              _buildUpdatesGrid(),
              SizedBox(height: 22),
              Text('Continue Reading', style: _sectionTitleStyle()),
              SizedBox(height: 12),
              _buildContinueReadingCard(),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  TextStyle _sectionTitleStyle() =>
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 0)],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search manga, author, tag...'
              ),
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.filter_list)),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['Action', 'Romance', 'Comedy', 'Drama', 'Fantasy'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ChoiceChip(
            label: Text(categories[index]),
            selected: index == 0,
            onSelected: (_) {},
            selectedColor: Colors.deepPurple[50],
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
                color: index == 0 ? Colors.deepPurple : Colors.grey[800]),
            elevation: 2,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCarousel(double width) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        separatorBuilder: (_, __) => SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = featured[index];
          return _FeaturedCard(item: item, width: width * 0.56);
        },
      ),
    );
  }

  Widget _buildUpdatesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: updates.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.05,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = updates[index];
        return _UpdateTile(item: item);
      },
    );
  }

  Widget _buildContinueReadingCard() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://picsum.photos/seed/continue/120/160',
              width: 80,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manga In Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Chapter 45 • Page 12', style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 12),
                LinearProgressIndicator(value: 0.46),
                SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.play_arrow),
                      label: Text('Continue'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(110, 40)),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton(onPressed: () {}, child: Text('Details'))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Map<String, String> item;
  final double width;
  const _FeaturedCard({required this.item, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [Colors.deepPurpleAccent, Colors.deepPurple]),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Opacity(
                opacity: 0.07,
                child: Image.network(item['image']!, fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                Text(item['title']!, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(item['author']!, style: TextStyle(color: Colors.white70)),
                SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.book),
                      label: Text('Read'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton(onPressed: () {}, child: Text('Details', style: TextStyle(color: Colors.white70)))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _UpdateTile extends StatelessWidget {
  final Map<String, String> item;
  const _UpdateTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(item['image']!, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(item['manga']!, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('• 2h ago', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, size: 18))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

