import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:notes_app/notes/data/models/note_dto.dart';

part 'notes_database.g.dart';

@DriftDatabase(tables: [Notes])
class NotesDatabase extends _$NotesDatabase {
  NotesDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'notes');
  }
}
