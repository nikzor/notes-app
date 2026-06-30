import 'package:flutter/material.dart';
import 'package:notes_app/notes/domain/models/note.dart';
import 'package:notes_app/notes/domain/repositories/notes_repository.dart';
import 'package:notes_app/notes/view/note_editor_page.dart';
import 'package:notes_app/notes/view/widgets/note_list_item.dart';
import 'package:notes_app/widgets/empty_stub.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({required this.notesRepository, super.key});

  final NotesRepository notesRepository;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await widget.notesRepository.getNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  Future<void> _createNote() async {
    final note = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorPage()),
    );
    if (note != null) {
      await widget.notesRepository.addNote(note);
      setState(() => _notes.insert(0, note));
    }
  }

  Future<void> _openNote(Note note) async {
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(initialNote: note)),
    );
    if (updatedNote != null) {
      await widget.notesRepository.updateNote(updatedNote);
      setState(() {
        final index = _notes.indexWhere((n) => n.id == note.id);
        _notes[index] = updatedNote;
      });
    }
  }

  Future<void> _deleteNote(Note note) async {
    setState(() => _notes.removeWhere((n) => n.id == note.id));
    await widget.notesRepository.deleteNote(note.id);
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const EmptyStub(
                  icon: Icons.note_alt_outlined,
                  message: 'No notes yet.\nTap + to create your first note.',
                )
              : ListView.separated(
                  itemCount: _notes.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return NoteListItem(
                      note: note,
                      onDismissed: () => _deleteNote(note),
                      onTap: () => _openNote(note),
                    );
                  },
                ),
    );
  }
}
