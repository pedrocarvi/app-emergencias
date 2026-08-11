import 'package:flutter/material.dart';
import '../app/app.dart';
import '../app/app_controller.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  static const copy = [
    (
      'Emergencias rurales, con más contexto.',
      'Ante una emergencia podemos compartir tu ubicación, información médica, contactos y la mejor forma de llegar hasta vos.',
    ),
    (
      'Tres botones. Nada más.',
      'Médico, bomberos o policía. Mantené presionado tres segundos y el pedido de ayuda sale con todo tu contexto.',
    ),
    (
      'Lo tuyo queda en tu teléfono.',
      'El recorrido de las últimas horas se guarda solo en tu celular y se envía únicamente si generás un SOS.',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context), i = c.onboardingIndex;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 132,
                  height: 132,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.medical.withValues(alpha: .1),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.line),
                        ),
                      ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.ink,
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              copy[i].$1,
              style: const TextStyle(
                fontSize: 31,
                height: 1.08,
                fontWeight: FontWeight.w600,
                letterSpacing: -.7,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              copy[i].$2,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: List.generate(
                3,
                (n) => Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.only(right: n < 2 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: n == i ? AppColors.ink : const Color(0xFFE0E0DC),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: c.nextOnboarding,
              child: const Text('Continuar'),
            ),
            TextButton(
              onPressed: () {
                c.completeSetup();
              },
              child: const Text(
                'Omitir',
                style: TextStyle(color: AppColors.faint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final rows = [
      ('Información médica', 'Listo', true),
      (
        'Contactos de emergencia',
        '${c.contacts.length}',
        c.contacts.isNotEmpty,
      ),
      ('Establecimiento', '${c.properties.length}', c.properties.isNotEmpty),
      ('Ruta de acceso', '2', true),
      (
        'Recorrido reciente',
        c.trailEnabled ? 'Activo' : 'Activar',
        c.trailEnabled,
      ),
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Configuración'),
            const SizedBox(height: 10),
            const ScreenTitle(
              'Tu protección está 80% configurada.',
              subtitle:
                  'Falta un paso. Cuanto más completo, mejor te encuentran.',
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: const LinearProgressIndicator(
                value: .8,
                minHeight: 6,
                color: AppColors.ok,
                backgroundColor: AppColors.lineSoft,
              ),
            ),
            const SizedBox(height: 28),
            ...rows.map(
              (r) => InkWell(
                onTap: r.$1 == 'Recorrido reciente'
                    ? () => c.go(AppScreen.trail)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.lineSoft),
                    ),
                  ),
                  child: Row(
                    children: [
                      StatusCircle(done: r.$3),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          r.$1,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: r.$3
                                ? FontWeight.w500
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        r.$2,
                        style: TextStyle(
                          fontSize: 14,
                          color: r.$3 ? AppColors.faint : AppColors.police,
                          fontWeight: r.$3 ? FontWeight.w400 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: c.completeSetup,
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
