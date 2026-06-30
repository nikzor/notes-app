import 'package:notes_app/notes/data/sources/notes_database.dart';
import 'package:notes_app/notes/data/sources/notes_local_data_source.dart';
import 'package:notes_app/notes/domain/models/note.dart';
import 'package:notes_app/notes/domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._localDataSource);

  final NotesLocalDataSource _localDataSource;

  @override
  Future<List<Note>> getNotes() async {
    final dtos = await _localDataSource.getNotes();
    return dtos.map(_toDomain).toList();
  }

  @override
  Future<Note?> getNote(String id) async {
    final dto = await _localDataSource.getNote(id);
    return dto == null ? null : _toDomain(dto);
  }

  @override
  Future<void> addNote(Note note) {
    return _localDataSource.upsertNote(_toDto(note));
  }

  @override
  Future<void> updateNote(Note note) {
    return _localDataSource.upsertNote(_toDto(note));
  }

  @override
  Future<void> deleteNote(String id) {
    return _localDataSource.deleteNote(id);
  }

  Note _toDomain(NoteDto dto) {
    return Note(
      id: dto.id,
      title: dto.title,
      content: dto.content,
      updatedAt: dto.updatedAt,
    );
  }

  NoteDto _toDto(Note note) {
    return NoteDto(
      id: note.id,
      title: note.title,
      content: note.content,
      updatedAt: note.updatedAt,
    );
  }
}
