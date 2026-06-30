import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/notes/bloc/notes_cubit.dart';
import 'package:notes_app/notes/domain/models/note.dart';
import 'package:notes_app/notes/view/note_editor_page.dart';
import 'package:notes_app/notes/view/widgets/note_list_item.dart';
import 'package:notes_app/widgets/empty_stub.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  Future<void> _createNote(BuildContext context) async {
    final cubit = context.read<NotesCubit>();
    final note = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorPage()),
    );
    if (note != null) {
      await cubit.addNote(note);
    }
  }

  Future<void> _openNote(BuildContext context, Note note) async {
    final cubit = context.read<NotesCubit>();
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(initialNote: note)),
    );
    if (updatedNote != null) {
      await cubit.updateNote(updatedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            onPressed: () => _createNote(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocConsumer<NotesCubit, NotesState>(
        listenWhen: (previous, current) =>
            current.status != NotesStatus.failure &&
            current.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        builder: (context, state) {
          if (state.status == NotesStatus.initial ||
              state.status == NotesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == NotesStatus.failure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Something went wrong.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<NotesCubit>().loadNotes(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.notes.isEmpty) {
            return const EmptyStub(
              icon: Icons.note_alt_outlined,
              message: 'No notes yet.\nTap + to create your first note.',
            );
          }
          return ListView.separated(
            itemCount: state.notes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final note = state.notes[index];
              return NoteListItem(
                note: note,
                onDismissed: () =>
                    context.read<NotesCubit>().deleteNote(note.id),
                onTap: () => _openNote(context, note),
              );
            },
          );
        },
      ),
    );
  }
}
