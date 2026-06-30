part of 'notes_cubit.dart';

enum NotesStatus { initial, loading, success, failure }

class NotesState extends Equatable {
  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.errorMessage,
  });

  final NotesStatus status;
  final List<Note> notes;

  /// Set on a failed [NotesCubit] call. Cleared on the next successful
  /// emit since [copyWith] does not merge it.
  final String? errorMessage;

  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    String? errorMessage,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage];
}
