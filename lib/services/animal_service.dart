import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal.dart';
import 'api_client.dart';

class AnimalsPage {
  final List<Animal> animals;
  final Map<String, dynamic>? pagination;

  const AnimalsPage({required this.animals, this.pagination});

  bool get hasMore {
    final page = pagination?['page'] as int?;
    final lastPage = pagination?['lastPage'] as int?;
    if (page == null || lastPage == null) return animals.isNotEmpty;
    return page < lastPage;
  }
}

class AnimalService {
  final Ref _ref;

  AnimalService(this._ref);

  Future<AnimalsPage> fetchAnimals({int page = 1, int limit = 10}) async {
    final dio = _ref.read(apiClientProvider);
    final response = await dio.get(
      '/animals',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final result = (data['result'] as List<dynamic>? ?? [])
        .map((e) => Animal.fromJson(e as Map<String, dynamic>))
        .toList();
    return AnimalsPage(
      animals: result,
      pagination: data['pagination'] as Map<String, dynamic>?,
    );
  }

  Future<void> likeAnimal(String animalId) async {
    final dio = _ref.read(apiClientProvider);
    await dio.post('/animals/$animalId/like');
  }

  Future<void> unlikeAnimal(String animalId) async {
    final dio = _ref.read(apiClientProvider);
    await dio.delete('/animals/$animalId/like');
  }

  Future<Animal> fetchAnimalById(String animalId) async {
    final dio = _ref.read(apiClientProvider);
    final response = await dio.get('/animals/$animalId');
    final data = response.data as Map<String, dynamic>;
    final result = data['result'] as Map<String, dynamic>? ?? data;
    return Animal.fromJson(result);
  }

  Future<List<dynamic>> fetchAnimalFilters() async {
    final dio = _ref.read(apiClientProvider);
    final response = await dio.get('/animals/filters');
    return (response.data as Map<String, dynamic>)['result'] as List<dynamic>;
  }
}

final animalServiceProvider = Provider<AnimalService>(
  (ref) => AnimalService(ref),
);
