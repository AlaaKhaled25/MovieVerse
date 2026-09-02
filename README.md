<div align="center">

# 🎬 MovieVerse

**A complete, real-world Flutter movie application** — the ITI Summer Internship 2026 graduation project.

REST API integration · Firebase Authentication · Provider state management · Local persistence · Clean MVC architecture · Polished UI/UX

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture & Code Organization](#-architecture--code-organization)
- [State Management](#-state-management)
- [Application Flow](#-application-flow)
- [Database Design](#-database-design)
- [API Integration](#-api-integration)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Building & Deployment](#-building--deployment)
- [Testing](#-testing)
- [Project Phases](#-project-phases)
- [Known Limitations](#-known-limitations)
- [License](#-license)

---

## 📺 Overview

MovieVerse is a portfolio-ready Flutter application that brings together every major concept from the internship into **one real product instance**: it fetches live movie data from **TMDB**, authenticates real users with **Firebase**, persists favourites and personal movie lists locally (SQFLite on mobile, SharedPreferences on web), manages all state reactively with **Provider**, and keeps everything organised under a clean **MVC architecture**.

It is designed not as a UI exercise but as a real product: professional folder structure, meaningful Git commits, full loading/error/empty states, high-contrast accessible UI, and a brand identity (splash, theme, colors) that is consistent across mobile and web.

---

## ✨ Features

### Authentication (Firebase)
- Register, Login and Logout with email/password
- Friendlier, human-readable error messages (e.g. *"Invalid email or password"*)
- Auth-state guarding: logged-out users see the login screen, logged-in users see the app

### Browsing & Search (TMDB)
- **Home** with four horizontal sections: Popular, Now Playing, Top Rated, Upcoming
- Pull-to-refresh on the home screen
- **Search** with a 500 ms debounce to avoid spamming the API
- Distinct states for *"type to search"* vs *"no results found for query"*

### Movie Details (extended metadata)
- Backdrop hero header, poster, title, overview, release date, rating, genres
- **Cast carousel** (actors), **studios** (production companies with logos)
- Metadata grid: runtime, budget, revenue, status, countries, languages, IMDb id
- Favourite + personal-list actions accessible right on the page

### Favourites & Personal Lists
- **Favourites**: add/remove, persisted locally
- Three **personal lists**: Watched / Watching / Want to Watch
- A movie can belong to **at most one** list at a time (single-membership logic)

### Profile
- Shows the authenticated user
- Logout button

### Splash & Branding
- Animated **gradient-hero splash screen** (fade/scale entrance) with a ~0.8 s minimum and a 3 s safety cap
- Matching **native boot splash** on Android and a **branded web boot-splash** (no white flash)

---

## 🛠️ Tech Stack

| Technology | Purpose | Package(s) |
|------------|---------|-----------|
| **Flutter** | Cross-platform mobile/web framework | `flutter` |
| **Dart** | Programming language | &mdash; |
| **TMDB API** | Movie data source (REST / JSON) | `http` |
| **Firebase Auth** | User authentication | `firebase_core`, `firebase_auth` |
| **Provider** | Reactive state management | `provider` |
| **SQFLite** | Local relational database (mobile) | `sqflite`, `path` |
| **SharedPreferences** | Local persistence fallback (web) | `shared_preferences` |
| **FlutterFire CLI** | Firebase configuration tooling | `flutterfire_cli` |

---

## 🏗️ Architecture & Code Organization

The project follows the **Model-View-Controller (MVC)** pattern, expanded slightly with **Provider** into four clean layers:

```
Widget (View)                     lib/views, lib/widgets
   │  context.watch / context.read
   ▼
Provider (reactive state)         lib/providers   (holds state, calls controller, notifyListeners)
   │  delegates the operation
   ▼
Controller (business logic)       lib/controllers (what to call, how to map errors)
   │
   ▼
Service / Database (low-level)    lib/services, lib/database (HTTP, JSON, SQLite)
```

### The separation of responsibilities

- **Model** — data structures (`Movie`, `MovieDetails`, `CastMember`, ...).
- **View** — screens and reusable widgets. API/database code never lives here.
- **Controller** — business logic: which endpoint to call, how to persist, friendly error mapping. Three concrete controllers: `AuthController`, `MovieController`, `FavouritesController`.
- **Provider / State** — thin reactive wrappers that hold the data the UI reacts to and delegate operations to controllers.

This separation means a change to the data source, an endpoint, or an error message never requires touching UI code.

---

## 🧠 State Management

All application state is managed with **Provider** (`ChangeNotifier` + `notifyListeners`). Widgets subscribe with `context.watch<T>()` (rebuild on change) or `context.read<T>()` (call once).

Providers are wired together in `lib/main.dart` via `MultiProvider`:

```dart
ChangeNotifierProvider(create: (_) => AuthProvider()),
ChangeNotifierProvider(
  create: (_) => MovieProvider(MovieController(TmdbApiService())),
),
ChangeNotifierProvider(
  create: (_) => MovieDetailsProvider(MovieController(TmdbApiService())),
),
ChangeNotifierProvider(create: (_) => FavouritesProvider()),
```

| Provider | State it owns | Delegates to |
|----------|---------------|--------------|
| `AuthProvider` | current user, auth loading | `AuthController` |
| `MovieProvider` | movies per endpoint, search results, loading/error | `MovieController` |
| `MovieDetailsProvider` | single-movie details/cast | `MovieController` |
| `FavouritesProvider` | favourites + the 3 list types | `FavouritesController` |

---

## 🧭 Application Flow

```
Splash (>= min time, < hard cap)
   └─ Auth (Login / Register)
        └─ Main (Bottom Navigation)
             ├─ Home       (Popular / Now Playing / Top Rated / Upcoming)
             ├─ Search     (debounced live search)
             ├─ Lists      (Watched / Watching / Want to Watch)
             ├─ Favourites
             └─ Profile
Tapping any movie → Movie Details (cast, studios, metadata, favourite, lists)
```

On login, favourites and personal lists are loaded from local storage so they survive app restarts / page reloads.

---

## 🗄️ Database Design

Local storage is handled differently per platform by `FavouritesController`:

### Mobile (SQFLite) — `lib/database/database_helper.dart`

Two tables are created by the `DatabaseHelper` singleton:

```sql
CREATE TABLE favourites (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL, poster_path TEXT, overview TEXT,
  release_date TEXT, vote_average REAL,
  backdrop_path TEXT, genre_ids TEXT, created_at INTEGER
);

CREATE TABLE movie_lists (
  id INTEGER PRIMARY KEY,
  list_type TEXT NOT NULL,           -- watched | watching | want_to_watch
  title TEXT NOT NULL, poster_path TEXT, overview TEXT,
  release_date TEXT, vote_average REAL,
  backdrop_path TEXT, created_at INTEGER
);
```

- **`favourites`** — stores favourited movies (full CRUD).
- **`movie_lists`** — stores list membership. `addToList()` first removes the movie from every list, enforcing **single membership**.

### Web (SharedPreferences) — in-memory + `localStorage`

There is no native SQLite on the web. `FavouritesController` detects `kIsWeb` and instead persists the full favourites/lists snapshot to **SharedPreferences** (browser `localStorage`), so data survives a page refresh. Android/iOS keep full durable SQLite persistence.

---

## 🌐 API Integration

All HTTP communication is isolated in `TmdbApiService` (`lib/services/tmdb_api_service.dart`). No widget ever makes a network call directly.

| Purpose | Endpoint | Called by |
|---------|----------|-----------|
| List movies | `GET /movie/{popular\|top_rated\|now_playing\|upcoming}` | `MovieProvider.loadMovies` |
| Search | `GET /search/movie?query=...` | `MovieProvider.search` |
| Details + cast | `GET /movie/{id}?append_to_response=credits` | `MovieDetailsProvider.loadDetails` |

The private `_getJson()` helper centralises network/timeout handling, JSON parsing, and friendly `ApiException` messages. The API key lives in `lib/config/api_config.dart`, which is **gitignored**.

---

## 📁 Project Structure

```
lib/
├── config/          # Local, gitignored API keys (api_config.dart)
├── models/          # Data models (Movie, MovieDetails, CastMember, ...)
├── views/           # Screens / pages (UI, incl. splash_screen.dart)
├── controllers/     # Business logic (Auth, Movie, Favourites controllers)
├── providers/       # Provider classes — thin reactive state
├── services/        # TMDB API service
├── database/        # SQFLite database helper
├── widgets/         # Reusable UI components (MovieCard, StateView, AuthForm)
├── utils/           # Theme, colors, helpers
├── firebase_options.dart  # Generated by FlutterFire
└── main.dart        # App entry + provider wiring

web/                 # Web entry (index.html with branded boot-splash)
android/             # Android native config (incl. branded launch background)
test/                # Unit/widget tests (widget_test.dart)
```

### Key files

| File | Responsibility |
|------|----------------|
| `lib/main.dart` | Initialises Firebase, wires all providers, shows the AuthGate |
| `lib/controllers/auth_controller.dart` | Firebase auth operations + friendly error mapping |
| `lib/controllers/movie_controller.dart` | TMDB endpoint selection, search, details + API error mapping |
| `lib/controllers/favourites_controller.dart` | Persistence rules (SQFLite mobile / SharedPreferences web) |
| `lib/providers/*` | Thin reactive state wrappers |
| `lib/services/tmdb_api_service.dart` | TMDB REST client |
| `lib/database/database_helper.dart` | SQFLite singleton + schema |
| `lib/views/splash_screen.dart` | Animated gradient-hero splash |
| `lib/views/auth_gate.dart` | Route guard (splash → auth → main) |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (stable) — the project was built on **3.44.9**
- A **TMDB** account + API key
- A **Firebase** project
- (Optional) Android Studio / Xcode / a web browser to run the app

### 1. Get the code

```bash
git clone https://github.com/AlaaKhaled25/MovieVerse.git
cd MovieVerse
flutter pub get
```

### 2. Configure the TMDB API

1. Create a free account at [themoviedb.org](https://www.themoviedb.org/).
2. Request an API key under **Settings → API**.
3. Create `lib/config/api_config.dart` with your key:

```dart
class ApiConfig {
  static const String tmdbApiKey = 'YOUR_TMDB_API_KEY_HERE';
}
```

> ⚠️ This file is **gitignored** — never commit a real key to a public repository.

### 3. Configure Firebase Authentication

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com/).
2. Enable **Email/Password** under Authentication → Sign-in method.
3. Add **Android** and/or **iOS** and/or **Web** apps.
4. Generate config with FlutterFire:

```bash
npm install -g firebase-tools
firebase login
flutterfire configure --project=<your-project-id> \
  --android-package-name=com.example.movie_verse --platforms=android,ios,web
```

This generates `lib/firebase_options.dart` and the platform config files (`google-services.json`, etc.).

### 4. Run the app

```bash
flutter run                          # a connected device / emulator
flutter run -d edge                  # or Chrome / Edge (web)
flutter run -d web-server --web-port=8080   # serve on localhost:8080
```

---

## 📦 Building & Deployment

| Target | Command | Output |
|--------|---------|--------|
| Android debug APK | `flutter build apk --debug` | `build/app/outputs/flutter-apk/app-debug.apk` |
| Android release APK | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android App Bundle | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |
| Web (production) | `flutter build web --release` | `build/web/` (static site) |
| iOS (release) | `flutter build ios --release` *(macOS + Xcode)* | archive via Xcode |

**Deploy the web build** to Firebase Hosting (or any static host):

```bash
firebase login
firebase init hosting      # set 'build/web' as the public directory
firebase deploy --only hosting
```

**Deploy to GitHub Pages (automatic via GitHub Actions)**

A workflow (`.github/workflows/deploy.yml`) builds the web app on every push to `main` and publishes it to Pages. To use it:

1. On GitHub: **Settings → Pages** → Source: **GitHub Actions**.
2. Push to `main`. The workflow runs `flutter analyze`, `flutter test`, builds with the correct `--base-href=/MovieVerse/`, then deploys.
3. Your app will be live at `https://<username>.github.io/MovieVerse/`.

> If you rename the repo, update the `--base-href` in the workflow to match the new sub-path. The `--base-href` flag overrides the `$FLUTTER_BASE_HREF` placeholder in `web/index.html`, so no code change is required.

---

## 🧪 Testing

The project includes automated tests for the data-parsing logic (the parts that don't require a device or Firebase):

```bash
flutter test
```

Current coverage: `Movie.fromJson` (valid + missing/empty fields) and `MovieDetails.fromJson` (cast, studios, metadata).

Check code quality with:

```bash
flutter analyze
```

The whole codebase passes `flutter analyze` with **zero issues** and all tests pass.

---

## 🧱 Project Phases

The project was built in testable phases, each with a meaningful Git commit:

1. **Setup & foundation** — Flutter project, dependencies, .gitignore
2. **Architecture & folder structure** — MVC layering, theme, colors, widgets
3. **TMDB integration & models** — service + models + loading/error/empty states
4. **Core screens** — Home, Details, Search (debounced)
5. **Firebase authentication** — register/login/logout with route guarding
6. **Provider state management** — app-wide reactive state
7. **Favourites (SQFLite) & movie lists** — full persistence + three lists
8. **Profile & UI/UX polish** — user journey, polish, accessibility
9. **Enhanced details** — cast, studios, metadata
10. **Web support & docs** — web platform + web-safe persistence
11. **Splash & explicit controllers** — branded splash, MVC controller layer

---

## ⚠️ Known Limitations

- **Favourites/lists are local-only** (SQFLite on mobile, SharedPreferences on web) and are not synced across devices or accounts.
- **Web persistence uses the browser's localStorage** — it is not durable SQLite; clearing site data removes it. Mobile remains the full-featured target.
- **Web auth on GitHub Pages** serves from a different origin than the local dev server; Firebase generally allows any origin, but the email/password redirect flow can behave differently on Pages. The Flow: browse/test on the hosted Pages URL, and use mobile (Android/iOS) for the fully reliable target.
- **iOS builds require macOS + Xcode** (unavailable on a Windows dev machine).
- API results depend on TMDB's **free-tier rate limits**.

---

## 📄 License

This project was created for **educational purposes** as part of the **ITI Summer Internship 2026** (Flutter track). It is not affiliated with or endorsed by TMDB or Firebase.
