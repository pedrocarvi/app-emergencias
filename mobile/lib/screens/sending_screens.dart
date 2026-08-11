import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/app.dart';
import '../app/app_controller.dart';
import '../core/theme.dart';
import '../models/domain.dart';
import '../widgets/common.dart';

class SendingScreen extends StatelessWidget {
  const SendingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context), color = incidentColor(c.activeType);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 42, 26, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: color,
                    backgroundColor: AppColors.lineSoft,
                  ),
                ),
                const SizedBox(width: 12),
                Eyebrow('Enviando', color: color),
              ],
            ),
            const SizedBox(height: 34),
            Text(
              'Enviando ${c.activeType.label}…',
              style: const TextStyle(
                fontSize: 31,
                height: 1.1,
                fontWeight: FontWeight.w600,
                letterSpacing: -.7,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Estamos intentando comunicar tu emergencia. No cierres la aplicación.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 40),
            _statusRow(
              'Ubicación encontrada',
              c.sendingStep >= 0,
              c.sendingStep >= 1 ? 'obtenida' : 'buscando…',
            ),
            _statusRow(
              'Conexión establecida',
              c.sendingStep >= 1,
              c.sendingStep >= 1 ? 'activa' : 'buscando…',
            ),
            _statusRow(
              'Enviando al centro de emergencias',
              c.sendingStep >= 2,
              null,
              border: false,
            ),
            const Spacer(),
            const Text(
              'Vamos a confirmarte cuando el centro reciba el SOS. Hasta entonces seguimos intentando.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.faint,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: c.cancelSending,
              child: const Text('Cancelar envío'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _statusRow(String text, bool done, String? note, {bool border = true}) =>
    Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: border
            ? const Border(bottom: BorderSide(color: AppColors.lineSoft))
            : null,
      ),
      child: Row(
        children: [
          StatusCircle(done: done),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          if (note != null)
            Text(
              note,
              style: const TextStyle(fontSize: 13, color: AppColors.faint),
            ),
        ],
      ),
    );

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 38, 26, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.fire,
                    backgroundColor: Color(0xFFF0E4D4),
                  ),
                ),
                SizedBox(width: 10),
                Eyebrow('Reintentando', color: AppColors.fire),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Todavía no pudimos enviar el SOS.',
              style: TextStyle(
                fontSize: 29,
                height: 1.12,
                fontWeight: FontWeight.w600,
                letterSpacing: -.6,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'No tenemos conexión en este momento. Seguiremos intentando automáticamente.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 28),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _offlineRow('SOS guardado en tu teléfono', done: true),
                  _offlineRow(
                    'Ubicación obtenida',
                    done: true,
                    note: 'guardada',
                  ),
                  _offlineRow('Sin conexión', warning: true),
                  _offlineRow(
                    'Próximo intento en ${c.retrySeconds} s',
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Te vamos a avisar en cuanto el centro de emergencias lo confirme. Mientras no esté confirmado, no lo damos por enviado.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.faint,
              ),
            ),
            if (c.errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                c.errorMessage!,
                style: const TextStyle(fontSize: 12, color: AppColors.fire),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: () => launchUrl(Uri.parse('tel:107')),
              child: const Text('Llamar por teléfono'),
            ),
            TextButton(
              onPressed: () => c.go(AppScreen.home),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text(
                'Volver al inicio',
                style: TextStyle(color: AppColors.faint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _offlineRow(
  String text, {
  bool done = false,
  bool warning = false,
  bool last = false,
  String? note,
}) => Container(
  padding: const EdgeInsets.all(15),
  decoration: BoxDecoration(
    border: last
        ? null
        : const Border(bottom: BorderSide(color: AppColors.lineSoft)),
  ),
  child: Row(
    children: [
      StatusCircle(done: done, warning: warning),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            color: done || warning ? AppColors.ink : AppColors.muted,
          ),
        ),
      ),
      if (note != null)
        Text(
          note,
          style: const TextStyle(fontSize: 13, color: AppColors.faint),
        ),
    ],
  ),
);
