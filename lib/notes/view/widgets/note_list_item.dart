import 'package:flutter/material.dart';
import 'package:notes_app/notes/domain/models/note.dart';

class NoteListItem extends StatelessWidget {
  const NoteListItem({required this.note, required this.onDismissed, super.key});

  final Note note;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      onDismissed: (_) => onDismissed(),
      child: ListTile(
        title: Text(note.title.isEmpty ? 'Untitled' : note.title),
        subtitle: Text(
          note.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
