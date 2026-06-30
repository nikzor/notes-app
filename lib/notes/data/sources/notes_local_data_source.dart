import 'package:drift/drift.dart';
import 'package:notes_app/notes/data/sources/notes_database.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteDto>> getNotes();
  Future<NoteDto?> getNote(String id);
  Future<void> upsertNote(NoteDto note);
  Future<void> deleteNote(String id);
}

class DriftNotesLocalDataSource implements NotesLocalDataSource {
  DriftNotesLocalDataSource(this._db);

  final NotesDatabase _db;

  @override
  Future<List<NoteDto>> getNotes() {
    return (_db.select(_db.notes)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<NoteDto?> getNote(String id) {
    return (_db.select(_db.notes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<void> upsertNote(NoteDto note) {
    return _db.into(_db.notes).insertOnConflictUpdate(note);
  }

  @override
  Future<void> deleteNote(String id) {
    return (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
  }
}
