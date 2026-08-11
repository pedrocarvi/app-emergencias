import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/domain.dart';

class LocalStore {
  late SharedPreferences _prefs;
  Future<void> initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  String? get token => _prefs.getString('auth_token');
  Future<void> setToken(String? value) => value == null
      ? _prefs.remove('auth_token')
      : _prefs.setString('auth_token', value);
  bool get onboardingSeen => _prefs.getBool('onboarding_seen') ?? false;
  Future<void> completeOnboarding() => _prefs.setBool('onboarding_seen', true);
  bool get trailEnabled => _prefs.getBool('trail_enabled') ?? false;
  Future<void> setTrailEnabled(bool v) => _prefs.setBool('trail_enabled', v);
  List<TrailPoint> get trail {
    final raw = _prefs.getString('recent_trail');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => TrailPoint.fromJson(Map<String, dynamic>.from(e)))
          .where(
            (e) => e.timestamp.isAfter(
              DateTime.now().subtract(const Duration(hours: 3)),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addTrailPoint(TrailPoint point) async {
    final items = [...trail, point];
    await _prefs.setString(
      'recent_trail',
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearTrail() => _prefs.remove('recent_trail');
  PendingIncident? get pending {
    final raw = _prefs.getString('pending_incident');
    if (raw == null) return null;
    try {
      return PendingIncident.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> setPending(PendingIncident? p) => p == null
      ? _prefs.remove('pending_incident')
      : _prefs.setString('pending_incident', jsonEncode(p.toJson()));
}
