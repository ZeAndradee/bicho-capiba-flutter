import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/animal.dart';
import 'api_client.dart';

class UserUpdateException implements Exception {
  final String message;
  const UserUpdateException(this.message);

  @override
  String toString() => message;
}

class UserService {
  final Ref _ref;

  UserService(this._ref);

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final dio = _ref.read(apiClientProvider);
    try {
      await dio.put('/users', data: data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null && status >= 200 && status < 300) {
        return;
      }
      if (status == 400) {
        throw const UserUpdateException(
          'Dados inválidos. Verifique os campos e tente novamente.',
        );
      }
      if (status == 422) {
        throw const UserUpdateException('Verifique os campos obrigatórios.');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const UserUpdateException(
          'Não foi possível conectar. Verifique sua internet e tente novamente.',
        );
      }
      throw const UserUpdateException('Algo deu errado. Tente novamente.');
    }
  }

  Future<List<Animal>> fetchFavorites() async {
    final dio = _ref.read(apiClientProvider);
    final response = await dio.get('/me/favorites');
    final data = response.data;
    final list = data is Map<String, dynamic>
        ? data['result'] as List<dynamic>? ?? const []
        : data as List<dynamic>? ?? const [];
    return list
        .map((e) => Animal.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final userServiceProvider = Provider<UserService>((ref) => UserService(ref));

final favoritesProvider = FutureProvider.autoDispose<List<Animal>>(
  (ref) => ref.read(userServiceProvider).fetchFavorites(),
);
