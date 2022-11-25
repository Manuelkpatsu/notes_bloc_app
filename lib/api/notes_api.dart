import 'package:flutter/foundation.dart' show immutable;
import 'package:note_bloc_app/models.dart';

@immutable
abstract class NotesApiProtocal {
  const NotesApiProtocal();

  Future<Iterable<Note>?> getNotes({required LoginHandle loginHandle});
}

@immutable
class NotesApi implements NotesApiProtocal {
  // singleton pattern
  const NotesApi._sharedInstance();
  static const NotesApi _shared = NotesApi._sharedInstance();
  factory NotesApi.instance() => _shared;

  @override
  Future<Iterable<Note>?> getNotes({required LoginHandle loginHandle}) =>
      Future.delayed(
        const Duration(seconds: 2),
        () => loginHandle == const LoginHandle.fooBar() ? mockNotes : null,
      );
}
