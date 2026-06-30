import 'package:flutter/material.dart';
import 'package:notes_app/notes/data/sources/notes_database.dart';
import 'package:notes_app/notes/data/sources/notes_local_data_source.dart';
import 'package:notes_app/notes/domain/repositories/notes_repository_impl.dart';
import 'package:notes_app/notes_app.dart';

void main() {
  final notesDatabase = NotesDatabase();
  final notesRepository = NotesRepositoryImpl(
    DriftNotesLocalDataSource(notesDatabase),
  );
  runApp(NotesApp(notesRepository: notesRepository));
}
