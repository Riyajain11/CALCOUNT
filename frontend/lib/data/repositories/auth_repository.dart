import 'dart:async';

class AuthUser {
  final String uid;
  final String email;
  final String displayName;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });
}

abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();
  AuthUser? get currentUser;
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> logOut();
  Future<void> deleteAccount(String password);
}

class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  FakeAuthRepository({bool startLoggedIn = true}) {
    if (startLoggedIn) {
      _currentUser = const AuthUser(
        uid: 'user_123',
        email: 'user@example.com',
        displayName: 'User',
      );
    }
  }

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters');
    }
    _currentUser = AuthUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: name,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = AuthUser(
      uid: 'user_123',
      email: email,
      displayName: email.split('@').first,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> logOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> deleteAccount(String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

