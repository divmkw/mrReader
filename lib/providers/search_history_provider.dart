// lib/providers/search_history_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/search_history_manager.dart';

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, List<String>>(
  () => SearchHistoryNotifier(),
);

class SearchHistoryNotifier extends AsyncNotifier<List<String>> {
  @override
  FutureOr<List<String>> build() async {
    final searches = await SearchHistoryManager().getRecentSearches();
    return searches;
  }

  Future<void> add(String query) async {
    if (query.trim().isEmpty) return;
    await SearchHistoryManager().addSearch(query.trim());
    final searches = await SearchHistoryManager().getRecentSearches();
    state = AsyncData(searches);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    state = const AsyncData([]);
  }
}
