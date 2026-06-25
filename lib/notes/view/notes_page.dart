import 'package:flutter/material.dart';
import 'package:notes_app/notes/domain/models/note.dart';
import 'package:notes_app/notes/view/new_note_page.dart';
import 'package:notes_app/widgets/empty_stub.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Note> _notes = [];

  Future<void> _createNote() async {
    final note = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => const NewNotePage()),
    );
    if (note != null) {
      setState(() => _notes.insert(0, note));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(onPressed: _createNote, icon: const Icon(Icons.add)),
        ],
      ),
      body: _notes.isEmpty
          ? const EmptyStub(
              icon: Icons.note_alt_outlined,
              message: 'No notes yet.\nTap + to create your first note.',
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return ListTile(
                  title: Text(
                    note.title.isEmpty ? 'Untitled' : note.title,
                  ),
                  subtitle: Text(
                    note.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
    );
  }
}
