import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/domain.dart';
import 'local_store.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.status});
  final String message;
  final int? status;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({required this.store, http.Client? client})
    : _client = client ?? http.Client();
  final LocalStore store;
  final http.Client _client;
  static String get baseUrl {
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) return defined;
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://127.0.0.1:3000';
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'));
    request.headers['Content-Type'] = 'application/json';
    if (auth && store.token != null) {
      request.headers['Authorization'] = 'Bearer ${store.token}';
    }
    if (body != null) request.body = jsonEncode(body);
    try {
      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 12));
      final response = await http.Response.fromStream(streamed);
      final data = response.body.isEmpty ? null : jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          data?['message'] ?? 'Error del servidor',
          status: response.statusCode,
        );
      }
      return data;
    } on SocketException {
      throw ApiException('Sin conexión');
    } on http.ClientException {
      throw ApiException('No se pudo conectar');
    }
  }

  Future<Map<String, dynamic>> requestOtp(String phone) => _send(
    'POST',
    '/auth/request-otp',
    body: {'phone': phone},
    auth: false,
  ).then((e) => Map<String, dynamic>.from(e));
  Future<void> verifyOtp(String phone, String otp) async {
    final data = await _send(
      'POST',
      '/auth/verify-otp',
      body: {'phone': phone, 'otp': otp},
      auth: false,
    );
    await store.setToken(data['token']);
  }

  Future<Map<String, dynamic>> me() =>
      _send('GET', '/users/me').then((e) => Map<String, dynamic>.from(e));
  Future<Map<String, dynamic>> saveMe(Map<String, dynamic> value) => _send(
    'PUT',
    '/users/me',
    body: value,
  ).then((e) => Map<String, dynamic>.from(e));
  Future<MedicalProfile> medical() async {
    final d = await _send('GET', '/users/me/medical-profile');
    return d == null
        ? MedicalProfile()
        : MedicalProfile.fromJson(Map<String, dynamic>.from(d));
  }

  Future<MedicalProfile> saveMedical(MedicalProfile value) => _send(
    'PUT',
    '/users/me/medical-profile',
    body: value.toJson(),
  ).then((e) => MedicalProfile.fromJson(Map<String, dynamic>.from(e)));
  Future<List<EmergencyContact>> contacts() => _send('GET', '/contacts').then(
    (e) => (e as List)
        .map((j) => EmergencyContact.fromJson(Map<String, dynamic>.from(j)))
        .toList(),
  );
  Future<EmergencyContact> createContact(Map<String, dynamic> value) => _send(
    'POST',
    '/contacts',
    body: value,
  ).then((e) => EmergencyContact.fromJson(Map<String, dynamic>.from(e)));
  Future<List<RuralProperty>> properties() => _send('GET', '/properties').then(
    (e) => (e as List)
        .map((j) => RuralProperty.fromJson(Map<String, dynamic>.from(j)))
        .toList(),
  );
  Future<RuralProperty> createProperty(Map<String, dynamic> value) => _send(
    'POST',
    '/properties',
    body: value,
  ).then((e) => RuralProperty.fromJson(Map<String, dynamic>.from(e)));
  Future<List<AccessRoute>> routes(String propertyId) =>
      _send('GET', '/properties/$propertyId/routes').then(
        (e) => (e as List)
            .map((j) => AccessRoute.fromJson(Map<String, dynamic>.from(j)))
            .toList(),
      );
  Future<AccessRoute> createRoute(
    String propertyId, {
    required String name,
    required String method,
    required List<TrailPoint> points,
  }) => _send(
    'POST',
    '/properties/$propertyId/routes',
    body: {
      'name': name,
      'creationMethod': method,
      'points': points
          .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
          .toList(),
    },
  ).then((e) => AccessRoute.fromJson(Map<String, dynamic>.from(e)));
  Future<Map<String, dynamic>> createIncident(PendingIncident p) => _send(
    'POST',
    '/incidents',
    body: {
      'clientIncidentId': p.clientIncidentId,
      'type': p.type.api,
      'latitude': p.location.latitude,
      'longitude': p.location.longitude,
      'accuracy': p.location.accuracy,
      'timestamp': p.location.timestamp.toUtc().toIso8601String(),
      'propertyId': p.propertyId,
    },
  ).then((e) => Map<String, dynamic>.from(e));
  Future<void> attachTrail(String id, List<TrailPoint> points) => _send(
    'POST',
    '/incidents/$id/location-points',
    body: {'points': points.map((e) => e.toJson()).toList()},
  );
  Future<Map<String, dynamic>> incident(String id) =>
      _send('GET', '/incidents/$id').then((e) => Map<String, dynamic>.from(e));
  Future<void> cancelIncident(String id) =>
      _send('POST', '/incidents/$id/cancel');
}
