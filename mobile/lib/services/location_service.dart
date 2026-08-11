import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import '../models/domain.dart';
import 'local_store.dart';

class LocationService {
  LocationService(this.store);
  final LocalStore store;
  StreamSubscription<Position>? _subscription;
  Future<bool> ensurePermission({bool background = false}) async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<TrailPoint> current() async {
    if (!await ensurePermission()) {
      throw StateError('Necesitás habilitar el GPS para generar un SOS.');
    }
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return _map(p);
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return _map(last);
      rethrow;
    }
  }

  Future<void> startTrail() async {
    if (_subscription != null) return;
    if (!await ensurePermission(background: true)) {
      throw StateError('No se otorgó permiso de ubicación.');
    }
    final LocationSettings settings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 50,
            intervalDuration: const Duration(minutes: 2),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'Recorrido reciente activo',
              notificationText:
                  'SOS Rural conserva el recorrido solo en este teléfono.',
              enableWakeLock: false,
            ),
          )
        : AppleSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 50,
            pauseLocationUpdatesAutomatically: true,
            showBackgroundLocationIndicator: true,
            activityType: ActivityType.automotiveNavigation,
          );
    _subscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((position) => store.addTrailPoint(_map(position)));
  }

  Future<void> stopTrail() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  TrailPoint _map(Position p) => TrailPoint(
    latitude: p.latitude,
    longitude: p.longitude,
    timestamp: p.timestamp,
    accuracy: p.accuracy,
    speed: p.speed,
    heading: p.heading,
  );
}
