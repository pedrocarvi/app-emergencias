import 'package:flutter/material.dart';
import '../app/app.dart';
import '../app/app_controller.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class TrailScreen extends StatelessWidget {
  const TrailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context),
        points = c.trail,
        first = points.isEmpty
            ? null
            : points.first.timestamp.add(const Duration(hours: 3));
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => c.go(AppScreen.profile),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Perfil'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.muted,
                padding: EdgeInsets.zero,
              ),
            ),
            const ScreenTitle(
              'Recorrido reciente',
              subtitle:
                  'Conservamos temporalmente en tu teléfono las últimas 3 horas de recorrido para poder compartirlas durante una emergencia.',
            ),
            const SizedBox(height: 24),
            AppCard(
              onTap: () => c.toggleTrail(!c.trailEnabled),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activar recorrido reciente',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 3),
                      ],
                    ),
                  ),
                  Switch(
                    value: c.trailEnabled,
                    onChanged: c.toggleTrail,
                    activeTrackColor: AppColors.ok,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                c.trailEnabled ? 'Activado · últimas 3 horas' : 'Desactivado',
                style: const TextStyle(fontSize: 13.5, color: AppColors.faint),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'Puede aumentar el consumo de batería.',
                style: TextStyle(fontSize: 13, color: AppColors.faint),
              ),
            ),
            if (c.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  c.errorMessage!,
                  style: const TextStyle(fontSize: 13, color: AppColors.fire),
                ),
              ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F5),
                border: Border.all(color: const Color(0xFFE3EAE6)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: AppColors.ok),
                      SizedBox(width: 9),
                      Text(
                        'Tu recorrido no se comparte',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Queda solo en tu teléfono y se borra a las 3 horas. Únicamente se envía si generás un SOS.',
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.55,
                      color: Color(0xFF4C6B58),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Eyebrow('Guardado ahora'),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _row('Puntos conservados', '${points.length}'),
                  _row(
                    'Se borra a las',
                    first == null
                        ? '—'
                        : '${first.hour.toString().padLeft(2, '0')}:${first.minute.toString().padLeft(2, '0')}',
                    last: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String a, String b, {bool last = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: AppColors.lineSoft)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            a,
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500),
          ),
        ),
        Text(b, style: const TextStyle(fontSize: 14, color: AppColors.faint)),
      ],
    ),
  );
}
