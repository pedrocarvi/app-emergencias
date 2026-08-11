import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../app/app.dart';
import '../app/app_controller.dart';
import '../core/theme.dart';
import '../models/domain.dart';
import '../widgets/common.dart';

class FieldsScreen extends StatelessWidget {
  const FieldsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: c.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 34),
          children: [
            const ScreenTitle('Mis campos'),
            const SizedBox(height: 22),
            ...c.properties.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: EdgeInsets.zero,
                  onTap: () => c.openProperty(p),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: RuralMap(
                          property: p,
                          height: 112,
                          interactive: false,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(17),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              p.locality ?? '',
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                _chip('${p.routeCount} rutas'),
                                if (p.entranceLatitude != null)
                                  _chip('Entrada registrada'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DashedAction(
              label: 'Agregar establecimiento',
              onTap: () => _addProperty(context, c),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _addProperty(BuildContext context, dynamic c) async {
  final name = TextEditingController(),
      locality = TextEditingController(),
      notes = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nuevo establecimiento'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: locality,
              decoration: const InputDecoration(labelText: 'Localidad'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Indicaciones de acceso',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
  if (ok == true && name.text.isNotEmpty) {
    final location = await c.locations.current();
    await c.api.createProperty({
      'name': name.text,
      'locality': locality.text,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'entranceLatitude': location.latitude,
      'entranceLongitude': location.longitude,
      'notes': notes.text,
    });
    await c.refresh();
  }
}

Widget _chip(String t) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.chip,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    t,
    style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
  ),
);

class RuralMap extends StatelessWidget {
  const RuralMap({
    super.key,
    required this.property,
    this.routes = const [],
    this.trail = const [],
    this.height = 300,
    this.interactive = true,
  });
  final RuralProperty property;
  final List<AccessRoute> routes;
  final List<TrailPoint> trail;
  final double height;
  final bool interactive;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(property.latitude, property.longitude),
        initialZoom: interactive ? 14 : 12,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'ar.sosrural.sos_rural',
        ),
        PolylineLayer(
          polylines: [
            ...routes.map(
              (r) => Polyline(
                points: r.points
                    .map((p) => LatLng(p.latitude, p.longitude))
                    .toList(),
                strokeWidth: 4.5,
                color: AppColors.police,
              ),
            ),
            if (trail.isNotEmpty)
              Polyline(
                points: trail
                    .map((p) => LatLng(p.latitude, p.longitude))
                    .toList(),
                strokeWidth: 4,
                color: AppColors.muted,
              ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(property.latitude, property.longitude),
              width: 34,
              height: 34,
              child: const Icon(
                Icons.location_pin,
                color: AppColors.medical,
                size: 34,
              ),
            ),
            if (property.entranceLatitude != null)
              Marker(
                point: LatLng(
                  property.entranceLatitude!,
                  property.entranceLongitude!,
                ),
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.ok,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
          ],
        ),
        RichAttributionWidget(
          attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
        ),
      ],
    ),
  );
}

class FieldDetailScreen extends StatelessWidget {
  const FieldDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context), p = c.selectedProperty;
    if (p == null) return const SizedBox();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            RuralMap(property: p, routes: c.selectedRoutes, height: 300),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 14,
              left: 18,
              child: FloatingActionButton.small(
                heroTag: 'backField',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.ink,
                onPressed: () => c.go(AppScreen.fields),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.5,
                ),
              ),
              Text(
                '${p.locality ?? ''}${p.areaHectares != null ? ' · ${p.areaHectares!.toStringAsFixed(0)} ha' : ''}',
                style: const TextStyle(fontSize: 15, color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(radius: 4, backgroundColor: AppColors.ok),
                        SizedBox(width: 9),
                        Text(
                          'Entrada principal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.notes ?? 'Sin indicaciones adicionales.',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Eyebrow('Rutas de acceso'),
              const SizedBox(height: 12),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: c.selectedRoutes.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(
                              'Todavía no hay rutas registradas.',
                              style: TextStyle(color: AppColors.muted),
                            ),
                          ),
                        ]
                      : c.selectedRoutes
                            .map(
                              (r) => ListTile(
                                leading: const Icon(
                                  Icons.route,
                                  color: AppColors.police,
                                ),
                                title: Text(r.name),
                                subtitle: Text(
                                  '${r.distance?.toStringAsFixed(1) ?? '—'} km · ${r.creationMethod == 'DRAWN' ? 'dibujada' : 'recorrida'}',
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFFC9C9C5),
                                ),
                              ),
                            )
                            .toList(),
                ),
              ),
              const SizedBox(height: 20),
              DashedAction(
                label: 'Agregar ruta',
                onTap: () => c.go(AppScreen.routeNew),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class RouteNewScreen extends StatelessWidget {
  const RouteNewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => c.go(AppScreen.field),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Establecimiento'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.muted,
                padding: EdgeInsets.zero,
              ),
            ),
            const ScreenTitle(
              'Crear una ruta',
              subtitle:
                  'Elegí cómo querés registrar el camino hasta el establecimiento.',
            ),
            const SizedBox(height: 24),
            _method(
              Icons.radio_button_checked,
              'Recorrer una ruta',
              'Conducí hasta el establecimiento y registramos el recorrido.',
              () => c.go(AppScreen.drive),
              dark: true,
            ),
            const SizedBox(height: 14),
            _method(
              Icons.gesture,
              'Dibujar una ruta',
              'Marcá manualmente el camino sobre el mapa.',
              () => c.go(AppScreen.draw),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _method(
  IconData icon,
  String title,
  String body,
  VoidCallback tap, {
  bool dark = false,
}) => AppCard(
  onTap: tap,
  padding: const EdgeInsets.all(24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: dark ? AppColors.ink : AppColors.policeSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: dark ? Colors.white : AppColors.police),
      ),
      const SizedBox(height: 18),
      Text(
        title,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      Text(
        body,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: AppColors.muted,
        ),
      ),
    ],
  ),
);

class DrawRouteScreen extends StatefulWidget {
  const DrawRouteScreen({super.key});
  @override
  State<DrawRouteScreen> createState() => _DrawRouteScreenState();
}

class _DrawRouteScreenState extends State<DrawRouteScreen> {
  final points = <TrailPoint>[];
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context), p = c.selectedProperty!;
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(p.latitude, p.longitude),
            initialZoom: 14,
            onTap: (_, latlng) => setState(
              () => points.add(
                TrailPoint(
                  latitude: latlng.latitude,
                  longitude: latlng.longitude,
                  timestamp: DateTime.now(),
                ),
              ),
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'ar.sosrural.sos_rural',
            ),
            PolylineLayer(polylines: drawRoutePolylines(points)),
            MarkerLayer(
              markers: points
                  .asMap()
                  .entries
                  .map(
                    (e) => Marker(
                      point: LatLng(e.value.latitude, e.value.longitude),
                      width: 14,
                      height: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: e.key == 0 ? AppColors.ok : AppColors.police,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 18,
          left: 18,
          right: 18,
          child: _floating(
            'Dibujá el camino',
            'Tocá el mapa para marcar cada punto. ${points.isEmpty ? 'Empezá por el acceso desde la ruta.' : '${points.length} puntos marcados'}',
            stacked: true,
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: MediaQuery.paddingOf(context).bottom + 20,
          child: Row(
            children: [
              _square(
                Icons.undo,
                () => setState(
                  () => points.isNotEmpty ? points.removeLast() : null,
                ),
              ),
              const SizedBox(width: 10),
              _square(Icons.close, () => setState(points.clear)),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: points.length < 2
                      ? null
                      : () => c.saveRoute(points, 'DRAWN'),
                  child: const Text('Guardar ruta'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DriveRouteScreen extends StatefulWidget {
  const DriveRouteScreen({super.key});
  @override
  State<DriveRouteScreen> createState() => _DriveRouteScreenState();
}

class _DriveRouteScreenState extends State<DriveRouteScreen> {
  final points = <TrailPoint>[];
  Timer? timer;
  DateTime start = DateTime.now();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      capture();
      timer = Timer.periodic(const Duration(seconds: 10), (_) => capture());
    });
  }

  Future<void> capture() async {
    try {
      final p = await AppScope.of(context).locations.current();
      if (mounted) setState(() => points.add(p));
    } catch (_) {}
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context), p = c.selectedProperty!;
    final mins = DateTime.now().difference(start).inMinutes;
    return Stack(
      children: [
        RuralMap(
          property: p,
          height: MediaQuery.sizeOf(context).height,
          trail: points,
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 18,
          left: 18,
          right: 18,
          child: _floating('●  Registrando ruta', 'Entrada norte'),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: MediaQuery.paddingOf(context).bottom + 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 30,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric('Tiempo', '$mins min'),
                    _metric('Puntos', '${points.length}'),
                    _metric('Estado', 'GPS'),
                  ],
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: points.length < 2
                      ? null
                      : () => c.saveRoute(points, 'RECORDED'),
                  child: const Text('Finalizar recorrido'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

List<Polyline> drawRoutePolylines(List<TrailPoint> points) {
  if (points.length < 2) return const [];
  return [
    Polyline(
      points: points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
      color: AppColors.police,
      strokeWidth: 4.5,
    ),
  ];
}

Widget _floating(String a, String b, {bool stacked = false}) => Container(
  padding: const EdgeInsets.all(15),
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: .95),
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Color(0x18000000), blurRadius: 18, offset: Offset(0, 4)),
    ],
  ),
  child: stacked
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              a,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              b,
              style: const TextStyle(fontSize: 13.5, color: AppColors.muted),
            ),
          ],
        )
      : Row(
          children: [
            Expanded(
              child: Text(
                a,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                b,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ),
          ],
        ),
);
Widget _square(IconData icon, VoidCallback tap) => SizedBox(
  width: 56,
  height: 56,
  child: ElevatedButton(
    onPressed: tap,
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
    ),
    child: Icon(icon),
  ),
);
Widget _metric(String a, String b) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(a, style: const TextStyle(fontSize: 12.5, color: AppColors.faint)),
    Text(b, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
  ],
);
