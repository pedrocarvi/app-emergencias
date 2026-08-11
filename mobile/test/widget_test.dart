import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sos_rural/models/domain.dart';
import 'package:sos_rural/screens/home_screen.dart';
import 'package:sos_rural/screens/fields_screens.dart';

void main() {
  testWidgets('el SOS sólo se dispara después de mantener tres segundos', (
    tester,
  ) async {
    IncidentType? sent;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SosHoldButton(
            type: IncidentType.medical,
            height: 150,
            wide: true,
            onComplete: (type) => sent = type,
          ),
        ),
      ),
    );

    final center = tester.getCenter(find.text('SOS Médico'));
    final gesture = await tester.startGesture(center);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(sent, isNull);
    await tester.pump(const Duration(milliseconds: 1001));
    expect(sent, IncidentType.medical);
    await gesture.up();
  });

  testWidgets('soltar antes de tiempo cancela el SOS', (tester) async {
    IncidentType? sent;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SosHoldButton(
            type: IncidentType.fire,
            height: 150,
            onComplete: (type) => sent = type,
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.textContaining('Bomberos')),
    );
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pump(const Duration(seconds: 3));
    expect(sent, isNull);
  });

  test('dibujar recorrido no crea polylines sin puntos suficientes', () {
    expect(drawRoutePolylines(const []), isEmpty);
    expect(
      drawRoutePolylines([
        TrailPoint(
          latitude: -32.93,
          longitude: -60.99,
          timestamp: DateTime(2026),
        ),
      ]),
      isEmpty,
    );
    expect(
      drawRoutePolylines([
        TrailPoint(
          latitude: -32.93,
          longitude: -60.99,
          timestamp: DateTime(2026),
        ),
        TrailPoint(
          latitude: -32.94,
          longitude: -61.00,
          timestamp: DateTime(2026),
        ),
      ]),
      hasLength(1),
    );
  });
}
