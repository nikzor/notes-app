import 'package:flutter/material.dart';
import 'package:notes_app/notes/domain/models/note.dart';

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({this.initialNote, super.key});

  final Note? initialNote;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final _titleController =
      TextEditingController(text: widget.initialNote?.title);
  late final _contentController =
      TextEditingController(text: widget.initialNote?.content);

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(
      context,
      Note(
        id: widget.initialNote?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNewNote = widget.initialNote == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNewNote ? 'New note' : 'Note'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              autofocus: isNewNote,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Note',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
