import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../screens/active_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/contacts_screen.dart';
import '../screens/fields_screens.dart';
import '../screens/home_screen.dart';
import '../screens/medical_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/sending_screens.dart';
import '../screens/trail_screen.dart';
import '../widgets/app_navigation.dart';
import 'app_controller.dart';

class SosRuralApp extends StatelessWidget {
  const SosRuralApp({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) => AppScope(
    controller: controller,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOS Rural',
      theme: buildTheme(),
      home: AnimatedBuilder(
        animation: controller,
        builder: (_, _) => _Router(controller),
      ),
    ),
  );
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);
  static AppController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

class _Router extends StatelessWidget {
  const _Router(this.c);
  final AppController c;
  @override
  Widget build(BuildContext context) {
    final body = switch (c.screen) {
      AppScreen.login => const AuthScreen(),
      AppScreen.onboarding => const OnboardingScreen(),
      AppScreen.setup => const SetupScreen(),
      AppScreen.home => const HomeScreen(),
      AppScreen.sending => const SendingScreen(),
      AppScreen.active => const ActiveScreen(),
      AppScreen.offline => const OfflineScreen(),
      AppScreen.medical => const MedicalScreen(),
      AppScreen.contacts => const ContactsScreen(),
      AppScreen.fields => const FieldsScreen(),
      AppScreen.field => const FieldDetailScreen(),
      AppScreen.routeNew => const RouteNewScreen(),
      AppScreen.drive => const DriveRouteScreen(),
      AppScreen.draw => const DrawRouteScreen(),
      AppScreen.trail => const TrailScreen(),
      AppScreen.profile => const ProfileScreen(),
    };
    final hasNav = [
      AppScreen.home,
      AppScreen.fields,
      AppScreen.contacts,
      AppScreen.profile,
    ].contains(c.screen);
    return Scaffold(
      body: SafeArea(top: false, bottom: false, child: body),
      bottomNavigationBar: hasNav ? AppNavigation(current: c.screen) : null,
    );
  }
}
