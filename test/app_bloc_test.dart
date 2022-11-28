import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:note_bloc_app/api/login_api.dart';
import 'package:note_bloc_app/api/notes_api.dart';
import 'package:note_bloc_app/bloc/actions.dart';
import 'package:note_bloc_app/bloc/app_bloc.dart';
import 'package:note_bloc_app/bloc/app_state.dart';
import 'package:note_bloc_app/models.dart';

const Iterable<Note> mockNotes = [
  Note(title: 'Note 1'),
  Note(title: 'Note 2'),
  Note(title: 'Note 3'),
];

@immutable
class DummyNotesApi implements NotesApiProtocal {
  final LoginHandle acceptedLoginHandle;
  final Iterable<Note>? notesReturnForAcceptedLoginHandle;

  const DummyNotesApi({
    required this.acceptedLoginHandle,
    required this.notesReturnForAcceptedLoginHandle,
  });

  const DummyNotesApi.empty()
      : acceptedLoginHandle = const LoginHandle.fooBar(),
        notesReturnForAcceptedLoginHandle = null;

  @override
  Future<Iterable<Note>?> getNotes({required LoginHandle loginHandle}) async {
    if (loginHandle == acceptedLoginHandle) {
      return notesReturnForAcceptedLoginHandle;
    } else {
      return null;
    }
  }
}

@immutable
class DummyLoginApi implements LoginApiProtocal {
  final String acceptedEmail;
  final String acceptedPassword;
  final LoginHandle handleToReturn;

  const DummyLoginApi({
    required this.acceptedEmail,
    required this.acceptedPassword,
    required this.handleToReturn,
  });

  const DummyLoginApi.empty()
      : acceptedEmail = '',
        acceptedPassword = '',
        handleToReturn = const LoginHandle.fooBar();

  @override
  Future<LoginHandle?> login({
    required String email,
    required String password,
  }) async {
    if (email == acceptedEmail && password == acceptedPassword) {
      return handleToReturn;
    } else {
      return null;
    }
  }
}

const acceptedLoginHandle = LoginHandle(token: 'ABC');

void main() {
  blocTest<AppBloc, AppState>(
    'Initial state of the bloc should be AppState.empty()',
    build: () => AppBloc(
      loginApi: const DummyLoginApi.empty(),
      notesApi: const DummyNotesApi.empty(),
      acceptedLoginHandle: acceptedLoginHandle,
    ),
    verify: (appState) => expect(appState.state, const AppState.empty()),
  );

  blocTest<AppBloc, AppState>(
    'Can we log in with correct cedentials?',
    build: () => AppBloc(
      loginApi: const DummyLoginApi(
        acceptedEmail: 'bar@baz.com',
        acceptedPassword: 'foo',
        handleToReturn: acceptedLoginHandle,
      ),
      notesApi: const DummyNotesApi.empty(),
      acceptedLoginHandle: acceptedLoginHandle,
    ),
    act: (appBloc) => appBloc.add(
      const LoginAction(email: 'bar@baz.com', password: 'foo'),
    ),
    expect: () => [
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: null,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      ),
    ],
  );

  blocTest<AppBloc, AppState>(
    'We should not be able to log in with invalid credentials',
    build: () => AppBloc(
      loginApi: const DummyLoginApi(
        acceptedEmail: 'foo@bar.com',
        acceptedPassword: 'baz',
        handleToReturn: acceptedLoginHandle,
      ),
      notesApi: const DummyNotesApi.empty(),
      acceptedLoginHandle: acceptedLoginHandle,
    ),
    act: (appBloc) => appBloc.add(
      const LoginAction(email: 'bar@baz.com', password: 'foo'),
    ),
    expect: () => [
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: null,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: LoginErrors.invalidHandle,
        loginHandle: null,
        fetchedNotes: null,
      ),
    ],
  );

  blocTest<AppBloc, AppState>(
    'Load some notes with a valid login handle',
    build: () => AppBloc(
      loginApi: const DummyLoginApi(
        acceptedEmail: 'foo@bar.com',
        acceptedPassword: 'baz',
        handleToReturn: acceptedLoginHandle,
      ),
      notesApi: const DummyNotesApi(
        acceptedLoginHandle: acceptedLoginHandle,
        notesReturnForAcceptedLoginHandle: mockNotes,
      ),
      acceptedLoginHandle: acceptedLoginHandle,
    ),
    act: (appBloc) {
      appBloc.add(const LoginAction(email: 'foo@bar.com', password: 'baz'));
      appBloc.add(const LoadNotesAction());
    },
    expect: () => [
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: null,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: mockNotes,
      ),
    ],
  );
}
