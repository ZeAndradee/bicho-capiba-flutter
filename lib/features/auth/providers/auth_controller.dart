import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/auth_user.dart';
import '../../../services/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;

  const AuthState(this.status, [this.user]);

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restore();
    return const AuthState(AuthStatus.loading);
  }

  AuthService get _service => ref.read(authServiceProvider);

  Future<void> _restore() async {
    try {
      final user = await _service.me();
      state = AuthState(AuthStatus.authenticated, user);
    } catch (_) {
      state = const AuthState(AuthStatus.unauthenticated);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final user = await _service.login(email: email, password: password);
    state = AuthState(AuthStatus.authenticated, user);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final user = await _service.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    state = AuthState(AuthStatus.authenticated, user);
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState(AuthStatus.unauthenticated);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
