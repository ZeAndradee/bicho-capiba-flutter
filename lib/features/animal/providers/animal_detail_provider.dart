import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/animal.dart';
import '../../../services/animal_service.dart';

final animalDetailProvider = FutureProvider.family<Animal, String>((ref, id) {
  return ref.read(animalServiceProvider).fetchAnimalById(id);
});
