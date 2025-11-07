import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/search_page.dart';
import 'screens/library_page.dart';
import 'screens/settings_page.dart';
import 'widgets/bottom_nav.dart';
import 'theme/app_theme.dart';
import 'screens/notificaiton_page.dart';

void main() {
  runApp(const MangaReaderApp());
}

class MangaReaderApp extends StatefulWidget {
  const MangaReaderApp({super.key});

  @override
  State<MangaReaderApp> createState() => _MangaReaderAppState();
}

class _MangaReaderAppState extends State<MangaReaderApp> {
  int _selectedIndex = 0;
  final ThemeMode _themeMode = ThemeMode.system;

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    LibraryPage(),
    SettingsPage(),
    NotificationPage(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  // void _changeTheme(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga Reader',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
