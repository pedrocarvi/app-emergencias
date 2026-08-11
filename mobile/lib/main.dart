import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/app_controller.dart';
import 'services/api_client.dart';
import 'services/local_store.dart';
import 'services/location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LocalStore();
  await store.initialize();
  final controller = AppController(
    api: ApiClient(store: store),
    store: store,
    locations: LocationService(store),
  );
  await controller.initialize();
  runApp(SosRuralApp(controller: controller));
}
