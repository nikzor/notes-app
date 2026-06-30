import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:notes_app/notes/domain/models/note.dart';
import 'package:notes_app/notes/domain/repositories/notes_repository.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._notesRepository) : super(const NotesState());

  final NotesRepository _notesRepository;

  Future<void> loadNotes() async {
    emit(state.copyWith(status: NotesStatus.loading));
    try {
      final notes = await _notesRepository.getNotes();
      emit(state.copyWith(status: NotesStatus.success, notes: notes));
    } catch (_) {
      emit(
        state.copyWith(
          status: NotesStatus.failure,
          errorMessage: 'Failed to load notes.',
        ),
      );
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await _notesRepository.addNote(note);
      emit(state.copyWith(notes: [note, ...state.notes]));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Failed to save note.'));
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _notesRepository.updateNote(note);
      final notes = [...state.notes];
      final index = notes.indexWhere((n) => n.id == note.id);
      notes[index] = note;
      emit(state.copyWith(notes: notes));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Failed to update note.'));
    }
  }

  Future<void> deleteNote(String id) async {
    final previousNotes = state.notes;
    emit(state.copyWith(notes: state.notes.where((n) => n.id != id).toList()));
    try {
      await _notesRepository.deleteNote(id);
    } catch (_) {
      emit(
        state.copyWith(
          notes: previousNotes,
          errorMessage: 'Failed to delete note.',
        ),
      );
    }
  }
}
