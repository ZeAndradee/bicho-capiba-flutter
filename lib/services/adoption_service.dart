import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/adocoes/models/adoption_form.dart';
import '../features/adocoes/models/adoption_process.dart';
import 'api_client.dart';

class AdoptionException implements Exception {
  final String message;
  const AdoptionException(this.message);

  @override
  String toString() => message;
}

class AdoptionService {
  final Ref _ref;

  AdoptionService(this._ref);

  Future<void> submitAdoption({
    required String animalId,
    required AdoptionForm form,
  }) async {
    final dio = _ref.read(apiClientProvider);
    try {
      await dio.post('/adoptions', data: {
        'animal_id': animalId,
        ...form.toJson(),
      });
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400) {
        throw const AdoptionException(
          'Verifique os campos preenchidos e tente novamente.',
        );
      }
      if (status == 422) {
        throw const AdoptionException(
          'Alguns campos são obrigatórios. Verifique e tente novamente.',
        );
      }
      if (status == 409) {
        throw const AdoptionException(
          'Você já enviou uma solicitação para este animal.',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AdoptionException(
          'Não foi possível conectar. Verifique sua internet e tente novamente.',
        );
      }
      throw const AdoptionException('Algo deu errado. Tente novamente.');
    }
  }

  Future<List<AdoptionProcess>> fetchAdoptions() async {
    final dio = _ref.read(apiClientProvider);
    final response = await dio.get('/adoptions');
    final data = response.data as Map<String, dynamic>;
    return (data['result'] as List<dynamic>? ?? [])
        .map((e) => AdoptionProcess.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final adoptionServiceProvider = Provider<AdoptionService>(
  (ref) => AdoptionService(ref),
);

final adoptionsProvider = FutureProvider.autoDispose<List<AdoptionProcess>>(
  (ref) => ref.read(adoptionServiceProvider).fetchAdoptions(),
);
