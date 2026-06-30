# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A Flutter notes app whose end goal is **fully offline semantic search** over notes, using an on-device Gemma model via `flutter_gemma` — no servers, everything stored and processed on-device.

- Target platform: **iOS first** (iOS 16+, A12 Bionic+, ideally 4GB+ RAM).
- The `notes` feature now has a full VGV 4-layer slice (data → domain → bloc → view) backed by Drift/SQLite. Search and the on-device Gemma embeddings/model lifecycle are not implemented yet. See "Planned architecture" below for where this is headed.

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

Plain `Navigator`-based navigation (`MaterialPageRoute`, `Navigator.push`/`pop`), no router package. The `notes` feature follows the VGV 4-layer pattern end to end (data → domain → bloc → view); `search` is still a UI-only stub.

- [lib/notes_app.dart](lib/notes_app.dart) — root `MaterialApp`; takes a `NotesRepository` (constructed in [lib/main.dart](lib/main.dart)) and passes it down to `HomePage`.
- [lib/app/view/home_page.dart](lib/app/view/home_page.dart) — app shell: `BottomNavigationBar` + `IndexedStack` switching between the Notes and Search tabs, preserving each tab's state across switches (tab switching does *not* go through `Navigator`). This is the composition point where the `notes` feature's `BlocProvider<NotesCubit>` is created from the injected `NotesRepository`, wrapping `NotesPage` — `NotesRepository` is never passed into the view layer directly.
- `lib/notes/` — Notes feature (VGV 4-layer):
  - `data/sources/notes_database.dart` — `NotesDatabase` (`@DriftDatabase`), opened via `drift_flutter`'s `driftDatabase()`.
  - `data/models/note_dto.dart` — Drift `Notes` table definition (`@DataClassName('NoteDto')`).
  - `data/sources/notes_local_data_source.dart` — `NotesLocalDataSource` abstract class + `DriftNotesLocalDataSource` impl; raw CRUD over the Drift table.
  - `domain/models/note.dart` — domain `Note` model (id, title, content, updatedAt).
  - `domain/repositories/notes_repository.dart` + `notes_repository_impl.dart` — `NotesRepository` abstraction and Drift-backed impl; maps `NoteDto` ⇄ domain `Note`, keeping Drift types out of everything above it.
  - `bloc/notes_cubit.dart` + `notes_state.dart` — `NotesCubit` (`Cubit<NotesState>`), the only thing the view layer talks to; owns `NotesRepository` and exposes `NotesState { status, notes }`.
  - [view/notes_page.dart](lib/notes/view/notes_page.dart) — `StatelessWidget`; reads `NotesCubit` via `context.read`/`BlocBuilder`, dispatches `loadNotes`/`addNote`/`updateNote`/`deleteNote` — never touches `NotesRepository` directly.
  - [view/note_editor_page.dart](lib/notes/view/note_editor_page.dart) — single screen used for **both** creating and viewing/editing a note (`initialNote: null` → create mode). Avoid re-splitting this into separate create/edit screens.
  - [view/widgets/note_list_item.dart](lib/notes/view/widgets/note_list_item.dart) — `Dismissible` list item (swipe to delete) with `onTap` to open the editor.
- `lib/search/view/search_page.dart` — search UI shell only (search field + empty/no-results stubs); not wired to any data source yet.
- [lib/widgets/empty_stub.dart](lib/widgets/empty_stub.dart) — shared empty-state widget reused by both the Notes and Search screens.

## Planned architecture (not yet implemented)

`search` and `model` features still need to be built out using the same VGV 4-layer pattern (data → domain → bloc → view) established by `notes`:

```
lib/<feature>/
├── data/sources/        # Drift data sources, flutter_gemma embedding source
├── data/models/         # raw DB models (DTOs)
├── domain/repositories/ # abstraction + impl
├── domain/models/       # domain models
├── bloc/                # Bloc/Cubit + events/state
└── view/                # widgets, pages
```

Planned: `search` (FTS5 + cosine similarity hybrid search) and `model` (flutter_gemma lifecycle: init/download).

Key technical decisions for that future work:
- **Storage**: Drift (SQLite) with FTS5 for full-text search.
- **Embeddings**: `flutter_gemma`, Gemma 3n E2B INT4-quantized model (~300–400MB), stored as JSON text in a `embedding` column on the notes table for the MVP.
- **Search**: hybrid — FTS5 for exact/keyword matches, cosine similarity over embeddings for semantic matches, merged and ranked.
- **Model download**: downloaded on first run into app Documents directory; must be excluded from iCloud backup on iOS (`NSURLIsExcludedFromBackupKey`).
- Re-indexing strategy on note edit and cosine-similarity performance at scale (10k+ notes, possibly needing a compute isolate) are still open questions.
