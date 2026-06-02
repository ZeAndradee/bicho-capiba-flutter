import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import 'api_client.dart';
import 'token_store.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final Ref _ref;

  AuthService(this._ref);

  Dio get _dio => _ref.read(apiClientProvider);

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );
      return await me();
    } on DioException catch (e) {
      throw _mapError(e, {
        401: 'E-mail ou senha incorretos.',
      });
    }
  }

  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {
          'fullName': fullName.trim(),
          'email': email.trim(),
          'password': password,
        },
      );
      return await me();
    } on DioException catch (e) {
      throw _mapError(e, {
        409: 'Já existe uma conta com este e-mail.',
        422: 'Dados inválidos. Confira os campos e tente novamente.',
      });
    }
  }

  Future<AuthUser> me() async {
    final response = await _dio.get('/auth/me');
    final data = response.data;
    final json = data is Map<String, dynamic>
        ? (data['authUser'] as Map<String, dynamic>? ??
              data['user'] as Map<String, dynamic>? ??
              data)
        : <String, dynamic>{};
    return AuthUser.fromJson(json);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (_) {
    } finally {
      await _ref.read(tokenStoreProvider).clear();
    }
  }

  AuthException _mapError(DioException e, Map<int, String> messages) {
    final status = e.response?.statusCode;
    if (status != null && messages.containsKey(status)) {
      return AuthException(messages[status]!);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AuthException(
        'Não foi possível conectar. Verifique sua internet e tente novamente.',
      );
    }
    return const AuthException('Algo deu errado. Tente novamente.');
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));
