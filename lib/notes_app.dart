import 'package:flutter/material.dart';
import 'package:notes_app/app/view/home_page.dart';
import 'package:notes_app/notes/domain/repositories/notes_repository.dart';

class NotesApp extends StatelessWidget {
  const NotesApp({required this.notesRepository, super.key});

  final NotesRepository notesRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(notesRepository: notesRepository),
    );
  }
}
