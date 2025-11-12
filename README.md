# Manga Reader (Flutter)

A Flutter app to browse, search, and bookmark manga using the MangaDex API. Built with Material 3, dark theme support, and a clean, responsive UI.

## Features
- Trending list powered by MangaDex (`/manga` with includes)
- Search with debounce and grid results
- Proper cover images with CDN URLs (no duplicate extensions)
- Ratings via statistics endpoint (Bayesian/average), rounded to 2 decimals
- Chapters count parsing and display
- Manga detail page with description, chapters, and bookmarking
- Bookmarks saved locally with SharedPreferences and shown in Library
- Themed UI (light/dark) with Material 3 components

## Screens
- Home: Trending and Top Rated lists
- Search: Debounced search with grid results
- Manga: Details, rating, chapters, description, bookmark toggle
- Library: Bookmarked manga from SharedPreferences
- Notifications: Sample list (dismiss, mark all read)
- Settings: Reading mode, appearance using SegmentedButton

## Tech Stack
- Flutter (Material 3)
- HTTP (`package:http`)
- SharedPreferences for local persistence

## Getting Started
### Prerequisites
- Flutter SDK installed (`flutter --version`)
- A device or emulator set up

### Install
```bash
flutter pub get
```

### Run
```bash
flutter run
```

## Project Structure (key files)
```
lib/
  main.dart                     # App entry
  theme/app_theme.dart          # Light/Dark themes
  bloc/manga_fecher.dart        # MangaDex API integration
  widgets/manga_card.dart       # Reusable card
  widgets/bottom_nav.dart       # Bottom navigation
  screens/
    home_page.dart
    search_page.dart
    manga_page.dart             # Detail + bookmark toggle (SharedPreferences)
    library_page.dart           # Loads bookmarks grid
    notificaiton_page.dart      # Example notifications
    settings_page.dart          # Reading & appearance settings
```

## API Notes (MangaDex)
- Base: `https://api.mangadex.org`
- Covers: `https://uploads.mangadex.org/covers/{mangaId}/{fileName}`
- Ratings: `/statistics/manga/{mangaId}` (uses `rating.bayesian` or `rating.average`)
- Requests include `includes[]=cover_art&includes[]=author` where needed

## Persistence
- Bookmarks stored under the SharedPreferences key `bookmarks` as a JSON array:
```json
[
  {
    "title": "...",
    "author": "...",
    "imageUrl": "...",
    "rating": 9.25,
    "chapters": 123,
    "description": "...",
    "lastRead": 0,
    "savedAt": "2025-01-01T00:00:00.000Z"
  }
]
```

## Linting & Formatting
- The codebase follows Flutter/Dart lints; avoid prints in production.
- Some APIs are updated for Flutter 3.24+ (e.g., `withValues(alpha: ...)`, SegmentedButton).

## Troubleshooting
- 404 cover images: Ensure `fileName` is used as-is; do NOT append extra `.jpg`.
- Ratings/chapters types: API may return strings; the UI safely parses them.
- If bookmarks don’t appear, pull-to-refresh the Library page.

## License
This project is for educational purposes. Check MangaDex terms when using their API/CDN.

