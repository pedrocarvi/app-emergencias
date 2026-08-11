import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/domain.dart';
import '../services/api_client.dart';
import '../services/local_store.dart';
import '../services/location_service.dart';

enum AppScreen {
  login,
  onboarding,
  setup,
  home,
  sending,
  active,
  offline,
  medical,
  contacts,
  fields,
  field,
  routeNew,
  drive,
  draw,
  trail,
  profile,
}

class AppController extends ChangeNotifier {
  AppController({
    required this.api,
    required this.store,
    required this.locations,
  });
  final ApiClient api;
  final LocalStore store;
  final LocationService locations;
  AppScreen screen = AppScreen.login;
  int onboardingIndex = 0, sendingStep = 0, retrySeconds = 15;
  IncidentType activeType = IncidentType.medical;
  DateTime? incidentTime;
  String? incidentId, errorMessage;
  String incidentStatus = 'PENDING_ATTENTION';
  bool busy = false, online = true;
  Map<String, dynamic> user = {
    'firstName': 'Juan',
    'lastName': 'Pereyra',
    'phone': '',
  };
  MedicalProfile medicalProfile = MedicalProfile();
  List<EmergencyContact> contacts = [];
  List<RuralProperty> properties = [];
  RuralProperty? selectedProperty;
  List<AccessRoute> selectedRoutes = [];
  Timer? _retryTimer, _statusTimer;
  int _sendGeneration = 0;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  bool get trailEnabled => store.trailEnabled;
  List<TrailPoint> get trail => store.trail;
  String get initials =>
      '${(user['firstName'] ?? 'J').toString()[0]}${(user['lastName'] ?? 'P').toString()[0]}'
          .toUpperCase();
  Future<void> initialize() async {
    _connectivity = Connectivity().onConnectivityChanged.listen((results) {
      online = !results.contains(ConnectivityResult.none);
      notifyListeners();
      if (online && store.pending != null) retryPending();
    });
    if (store.trailEnabled) {
      try {
        await locations.startTrail();
      } catch (_) {}
    }
    if (store.token == null) {
      screen = AppScreen.login;
    } else {
      screen = store.onboardingSeen ? AppScreen.home : AppScreen.onboarding;
      await refresh();
    }
    final pending = store.pending;
    if (pending != null) {
      activeType = pending.type;
      screen = AppScreen.offline;
      _startRetry();
    }
    notifyListeners();
  }

  Future<void> login(String phone, String otp) async {
    busy = true;
    errorMessage = null;
    notifyListeners();
    try {
      if (otp.isEmpty) {
        await api.requestOtp(phone);
      } else {
        await api.verifyOtp(phone, otp);
        await refresh();
        screen = AppScreen.onboarding;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (store.token == null) return;
    try {
      final results = await Future.wait([
        api.me(),
        api.medical(),
        api.contacts(),
        api.properties(),
      ]);
      user = results[0] as Map<String, dynamic>;
      medicalProfile = results[1] as MedicalProfile;
      contacts = results[2] as List<EmergencyContact>;
      properties = results[3] as List<RuralProperty>;
    } catch (e) {
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  void go(AppScreen value) {
    screen = value;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> nextOnboarding() async {
    if (onboardingIndex < 2) {
      onboardingIndex++;
      notifyListeners();
    } else {
      await store.completeOnboarding();
      go(AppScreen.setup);
    }
  }

  Future<void> completeSetup() async {
    await store.completeOnboarding();
    go(AppScreen.home);
  }

  Future<void> sendSos(IncidentType type) async {
    final generation = ++_sendGeneration;
    activeType = type;
    incidentTime = DateTime.now();
    sendingStep = 0;
    errorMessage = null;
    screen = AppScreen.sending;
    notifyListeners();
    late final TrailPoint location;
    try {
      location = await locations.current();
    } catch (e) {
      if (generation != _sendGeneration) return;
      errorMessage = e.toString();
      screen = AppScreen.home;
      notifyListeners();
      return;
    }
    if (generation != _sendGeneration) return;
    sendingStep = 1;
    notifyListeners();
    final pending = PendingIncident(
      clientIncidentId: const Uuid().v4(),
      type: type,
      location: location,
      propertyId: _nearestPropertyId(location),
    );
    await store.setPending(pending);
    try {
      final result = await api.createIncident(pending);
      incidentId = result['id'];
      incidentStatus = result['status'];
      if (generation != _sendGeneration) {
        await api.cancelIncident(incidentId!);
        await store.setPending(null);
        return;
      }
      await store.setPending(pending.copyWith(serverId: incidentId));
      sendingStep = 2;
      online = true;
      notifyListeners();
      if (store.trailEnabled && trail.isNotEmpty) {
        await api.attachTrail(incidentId!, trail);
      }
      await Future<void>.delayed(const Duration(milliseconds: 550));
      await store.setPending(null);
      screen = AppScreen.active;
      _pollStatus();
    } catch (e) {
      if (generation != _sendGeneration) return;
      errorMessage = e.toString();
      online = false;
      screen = AppScreen.offline;
      _startRetry();
    }
    notifyListeners();
  }

  Future<void> cancelSending() async {
    _sendGeneration++;
    _retryTimer?.cancel();
    final serverId = incidentId ?? store.pending?.serverId;
    await store.setPending(null);
    screen = AppScreen.home;
    notifyListeners();
    if (serverId != null) {
      try {
        await api.cancelIncident(serverId);
      } catch (_) {}
    }
  }

  Future<void> retryPending() async {
    final pending = store.pending;
    if (pending == null) return;
    try {
      final result = await api.createIncident(pending);
      incidentId = result['id'];
      incidentStatus = result['status'];
      if (store.trailEnabled && trail.isNotEmpty) {
        await api.attachTrail(incidentId!, trail);
      }
      await store.setPending(null);
      online = true;
      screen = AppScreen.active;
      _retryTimer?.cancel();
      _pollStatus();
    } catch (_) {
      online = false;
      retrySeconds = 15;
    }
    notifyListeners();
  }

  void _startRetry() {
    _retryTimer?.cancel();
    retrySeconds = 15;
    _retryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      retrySeconds--;
      if (retrySeconds <= 0) {
        retrySeconds = 15;
        retryPending();
      }
      notifyListeners();
    });
  }

  void _pollStatus() {
    _statusTimer?.cancel();
    if (incidentId == null) return;
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final value = await api.incident(incidentId!);
        incidentStatus = value['status'];
        if (['RESOLVED', 'CANCELLED'].contains(value['status'])) {
          _statusTimer?.cancel();
        }
        notifyListeners();
      } catch (_) {}
    });
  }

  Future<void> cancelIncident() async {
    if (incidentId != null) {
      try {
        await api.cancelIncident(incidentId!);
      } catch (_) {}
    }
    _statusTimer?.cancel();
    go(AppScreen.home);
  }

  Future<void> toggleTrail(bool value) async {
    if (value) {
      try {
        await locations.startTrail();
        await store.setTrailEnabled(true);
      } catch (e) {
        errorMessage = e.toString();
      }
    } else {
      await locations.stopTrail();
      await store.setTrailEnabled(false);
      await store.clearTrail();
    }
    notifyListeners();
  }

  Future<void> saveMedical(MedicalProfile value) async {
    busy = true;
    notifyListeners();
    try {
      medicalProfile = await api.saveMedical(value);
      go(AppScreen.profile);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> savePersonal(Map<String, dynamic> value) async {
    busy = true;
    notifyListeners();
    try {
      user = await api.saveMe(value);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> openProperty(RuralProperty value) async {
    selectedProperty = value;
    selectedRoutes = [];
    screen = AppScreen.field;
    notifyListeners();
    try {
      selectedRoutes = await api.routes(value.id);
    } catch (e) {
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> saveRoute(List<TrailPoint> points, String method) async {
    if (selectedProperty == null || points.length < 2) return;
    busy = true;
    notifyListeners();
    try {
      final route = await api.createRoute(
        selectedProperty!.id,
        name: method == 'DRAWN' ? 'Ruta dibujada' : 'Ruta recorrida',
        method: method,
        points: points,
      );
      selectedRoutes.add(route);
      go(AppScreen.field);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  String? _nearestPropertyId(TrailPoint point) {
    if (properties.isEmpty) return null;
    RuralProperty? nearest;
    var bestSquaredMeters = double.infinity;
    for (final property in properties) {
      final northSouth = (point.latitude - property.latitude) * 111000;
      final eastWest = (point.longitude - property.longitude) * 93000;
      final squaredMeters = (northSouth * northSouth) + (eastWest * eastWest);
      if (squaredMeters < bestSquaredMeters) {
        bestSquaredMeters = squaredMeters;
        nearest = property;
      }
    }
    return bestSquaredMeters <= 400000000 ? nearest?.id : null;
  }

  Future<void> logout() async {
    await store.setToken(null);
    screen = AppScreen.login;
    notifyListeners();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _statusTimer?.cancel();
    _connectivity?.cancel();
    locations.stopTrail();
    super.dispose();
  }
}
