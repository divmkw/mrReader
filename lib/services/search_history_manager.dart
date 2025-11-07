// import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryManager {
  static final String _key = 'recent_searches';

  Future<List<String>> getRecentSearches() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> addSearch(String search) async {
    final List<String> searches = await getRecentSearches();
    
    if (searches.contains(search)) {
      searches.removeWhere((element) => element == search);
    }
    
    searches.insert(0, search); // Add to beginning instead of end

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, searches.take(5).toList());
  }
}
