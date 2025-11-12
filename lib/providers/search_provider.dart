// lib/providers/search_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/manga_fetcher.dart';

final searchProvider =
    AsyncNotifierProvider<SearchNotifier, List<Map<String, dynamic>>>(
  () => SearchNotifier(),
);

class SearchNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  Timer? _debounce;

  @override
  FutureOr<List<Map<String, dynamic>>> build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return [];
  }

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (query.trim().isEmpty) {
        state = const AsyncData([]);
        return;
      }

      state = const AsyncLoading();
      try {
        final results = await MangaDexApi.searchManga(query, limit: 20);
        state = AsyncData(results);
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    });
  }

  // @override
  // void dispose() {
  //   _debounce?.cancel();
  //   super.dispose();
  // }
}
