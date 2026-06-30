# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A Flutter notes app whose end goal is **fully offline semantic search** over notes, using an on-device Gemma model via `flutter_gemma` — no servers, everything stored and processed on-device.

- Target platform: **iOS first** (iOS 16+, A12 Bionic+, ideally 4GB+ RAM).
- The codebase is currently an early UI prototype: navigation and the Notes screens are built with local widget state (no persistence, no bloc, no embeddings yet). See "Planned architecture" below for where this is headed.

## Commands

```bash
flutter pub get        # install dependencies
flutter analyze        # static analysis (uses flutter_lints via analysis_options.yaml)
flutter test            # run tests (no test/ directory exists yet)
flutter devices         # list available simulators/devices
flutter run -d <id>     # run on a specific device, e.g. an iOS simulator
```

There is no test suite yet — when adding one, standard `flutter test` / `flutter test test/some_test.dart` applies.

## Current architecture

Plain `Navigator`-based navigation (`MaterialPageRoute`, `Navigator.push`/`pop`), no router package. Screens use `StatefulWidget` + local state rather than blocs — that wiring comes later.

- [lib/notes_app.dart](lib/notes_app.dart) — root `MaterialApp`, points `home` at `HomePage`.
- [lib/app/view/home_page.dart](lib/app/view/home_page.dart) — app shell: `BottomNavigationBar` + `IndexedStack` switching between the Notes and Search tabs, preserving each tab's state across switches (tab switching does *not* go through `Navigator`).
- `lib/notes/` — Notes feature:
  - [domain/models/note.dart](lib/notes/domain/models/note.dart) — placeholder `Note` model (id, title, content, updatedAt); will move under a proper data/domain split once persistence is added.
  - [view/notes_page.dart](lib/notes/view/notes_page.dart) — list of notes with an empty-state stub, `+` button pushes the editor via `Navigator`.
  - [view/note_editor_page.dart](lib/notes/view/note_editor_page.dart) — single screen used for **both** creating and viewing/editing a note (`initialNote: null` → create mode). Avoid re-splitting this into separate create/edit screens.
  - [view/widgets/note_list_item.dart](lib/notes/view/widgets/note_list_item.dart) — `Dismissible` list item (swipe to delete) with `onTap` to open the editor.
- `lib/search/view/search_page.dart` — search UI shell only (search field + empty/no-results stubs); not wired to any data source yet.
- [lib/widgets/empty_stub.dart](lib/widgets/empty_stub.dart) — shared empty-state widget reused by both the Notes and Search screens.

## Planned architecture (not yet implemented)

The project is meant to grow into a **VGV 4-layer architecture** (data → domain → bloc → view) per feature, using `flutter_bloc` for state management:

```
lib/<feature>/
├── data/sources/        # Drift data sources, flutter_gemma embedding source
├── data/models/         # raw DB models (DTOs)
├── domain/repositories/ # abstraction + impl
├── domain/models/       # domain models
├── bloc/                # Bloc/Cubit + events/state
└── view/                # widgets, pages
```

Planned features beyond `notes`: `search` (FTS5 + cosine similarity hybrid search) and `model` (flutter_gemma lifecycle: init/download).

Key technical decisions for that future work:
- **Storage**: Drift (SQLite) with FTS5 for full-text search.
- **Embeddings**: `flutter_gemma`, Gemma 3n E2B INT4-quantized model (~300–400MB), stored as JSON text in a `embedding` column on the notes table for the MVP.
- **Search**: hybrid — FTS5 for exact/keyword matches, cosine similarity over embeddings for semantic matches, merged and ranked.
- **Model download**: downloaded on first run into app Documents directory; must be excluded from iCloud backup on iOS (`NSURLIsExcludedFromBackupKey`).
- Re-indexing strategy on note edit and cosine-similarity performance at scale (10k+ notes, possibly needing a compute isolate) are still open questions.
