import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String?> currentStreet() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isEmpty) return null;

    final p = placemarks.first;
    for (final value in [p.thoroughfare, p.street, p.subLocality]) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

class LocationNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return ref.read(locationServiceProvider).currentStreet();
  }
}

final userLocationProvider = AsyncNotifierProvider<LocationNotifier, String?>(
  LocationNotifier.new,
);
