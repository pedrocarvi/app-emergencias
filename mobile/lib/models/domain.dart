enum IncidentType { medical, fire, police }

extension IncidentTypeX on IncidentType {
  String get api => switch (this) {
    IncidentType.medical => 'MEDICAL',
    IncidentType.fire => 'FIRE',
    IncidentType.police => 'POLICE',
  };
  String get label => switch (this) {
    IncidentType.medical => 'SOS Médico',
    IncidentType.fire => 'SOS Bomberos',
    IncidentType.police => 'SOS Policía',
  };
  String get short => switch (this) {
    IncidentType.medical => 'Médico',
    IncidentType.fire => 'Bomberos',
    IncidentType.police => 'Policía',
  };
}

class TrailPoint {
  const TrailPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.speed,
    this.heading,
  });
  final double latitude, longitude;
  final DateTime timestamp;
  final double? accuracy, speed, heading;
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'accuracy': accuracy,
    'speed': speed,
    'heading': heading,
  };
  factory TrailPoint.fromJson(Map<String, dynamic> j) => TrailPoint(
    latitude: (j['latitude'] as num).toDouble(),
    longitude: (j['longitude'] as num).toDouble(),
    timestamp: DateTime.parse(j['timestamp']),
    accuracy: (j['accuracy'] as num?)?.toDouble(),
    speed: (j['speed'] as num?)?.toDouble(),
    heading: (j['heading'] as num?)?.toDouble(),
  );
}

class PendingIncident {
  const PendingIncident({
    required this.clientIncidentId,
    required this.type,
    required this.location,
    this.serverId,
    this.propertyId,
  });
  final String clientIncidentId;
  final IncidentType type;
  final TrailPoint location;
  final String? serverId;
  final String? propertyId;
  PendingIncident copyWith({String? serverId}) => PendingIncident(
    clientIncidentId: clientIncidentId,
    type: type,
    location: location,
    serverId: serverId ?? this.serverId,
    propertyId: propertyId,
  );
  Map<String, dynamic> toJson() => {
    'clientIncidentId': clientIncidentId,
    'type': type.api,
    'location': location.toJson(),
    'serverId': serverId,
    'propertyId': propertyId,
  };
  factory PendingIncident.fromJson(Map<String, dynamic> j) => PendingIncident(
    clientIncidentId: j['clientIncidentId'],
    type: IncidentType.values.firstWhere((e) => e.api == j['type']),
    location: TrailPoint.fromJson(Map<String, dynamic>.from(j['location'])),
    serverId: j['serverId'],
    propertyId: j['propertyId'],
  );
}

class MedicalProfile {
  MedicalProfile({
    this.bloodType = '0',
    this.bloodFactor = '+',
    this.allergies = '',
    this.medications = '',
    this.notes = '',
    this.hasDiabetes = false,
    this.hasEpilepsy = false,
    this.cardiovascularConditions = '',
  });
  String? bloodType, bloodFactor;
  String allergies, medications, notes, cardiovascularConditions;
  bool hasDiabetes, hasEpilepsy;
  Map<String, dynamic> toJson() => {
    'bloodType': bloodType,
    'bloodFactor': bloodFactor,
    'allergies': allergies,
    'chronicConditions': '',
    'medications': medications,
    'hasDiabetes': hasDiabetes,
    'hasEpilepsy': hasEpilepsy,
    'cardiovascularConditions': cardiovascularConditions,
    'notes': notes,
  };
  factory MedicalProfile.fromJson(Map<String, dynamic> j) => MedicalProfile(
    bloodType: j['bloodType'],
    bloodFactor: j['bloodFactor'],
    allergies: j['allergies'] ?? '',
    medications: j['medications'] ?? '',
    notes: j['notes'] ?? '',
    hasDiabetes: j['hasDiabetes'] ?? false,
    hasEpilepsy: j['hasEpilepsy'] ?? false,
    cardiovascularConditions: j['cardiovascularConditions'] ?? '',
  );
}

class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.notifyMedical,
    required this.notifyFire,
    required this.notifyPolice,
  });
  final String id, name, phone, relationship;
  final bool notifyMedical, notifyFire, notifyPolice;
  factory EmergencyContact.fromJson(Map<String, dynamic> j) => EmergencyContact(
    id: j['id'],
    name: j['name'],
    phone: j['phone'],
    relationship: j['relationship'],
    notifyMedical: j['notifyMedical'],
    notifyFire: j['notifyFire'],
    notifyPolice: j['notifyPolice'],
  );
}

class RuralProperty {
  const RuralProperty({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.locality,
    this.areaHectares,
    this.entranceLatitude,
    this.entranceLongitude,
    this.notes,
    this.routeCount = 0,
  });
  final String id, name;
  final String? locality, notes;
  final double latitude, longitude;
  final double? areaHectares, entranceLatitude, entranceLongitude;
  final int routeCount;
  factory RuralProperty.fromJson(Map<String, dynamic> j) => RuralProperty(
    id: j['id'],
    name: j['name'],
    locality: j['locality'],
    areaHectares: (j['areaHectares'] as num?)?.toDouble(),
    latitude: (j['latitude'] as num).toDouble(),
    longitude: (j['longitude'] as num).toDouble(),
    entranceLatitude: (j['entranceLatitude'] as num?)?.toDouble(),
    entranceLongitude: (j['entranceLongitude'] as num?)?.toDouble(),
    notes: j['notes'],
    routeCount: (j['routeCount'] as num?)?.toInt() ?? 0,
  );
}

class AccessRoute {
  const AccessRoute({
    required this.id,
    required this.name,
    required this.creationMethod,
    required this.points,
    this.distance,
    this.notes,
  });
  final String id, name, creationMethod;
  final double? distance;
  final String? notes;
  final List<TrailPoint> points;
  factory AccessRoute.fromJson(Map<String, dynamic> j) => AccessRoute(
    id: j['id'],
    name: j['name'],
    creationMethod: j['creationMethod'],
    distance: (j['distance'] as num?)?.toDouble(),
    notes: j['notes'],
    points: (j['points'] as List)
        .map(
          (p) => TrailPoint(
            latitude: (p['latitude'] as num).toDouble(),
            longitude: (p['longitude'] as num).toDouble(),
            timestamp: DateTime.now(),
          ),
        )
        .toList(),
  );
}
