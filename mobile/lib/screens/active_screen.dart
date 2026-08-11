import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/app.dart';
import '../core/theme.dart';
import '../models/domain.dart';
import '../widgets/common.dart';

class ActiveScreen extends StatelessWidget {
  const ActiveScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final color = incidentColor(c.activeType);
    final time = c.incidentTime == null
        ? '—'
        : '${c.incidentTime!.hour.toString().padLeft(2, '0')}:${c.incidentTime!.minute.toString().padLeft(2, '0')}';
    final attended =
        c.incidentStatus == 'ATTENDED' || c.incidentStatus == 'RESOLVED';
    final resolved = c.incidentStatus == 'RESOLVED';
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: color,
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.paddingOf(context).top + 24,
              24,
              26,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Eyebrow(
                      '${c.activeType.label} activo',
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  resolved
                      ? 'Tu emergencia fue resuelta.'
                      : attended
                      ? 'Tu emergencia está siendo atendida.'
                      : 'Tu emergencia fue recibida.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    height: 1.12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'El centro de emergencias está viendo tu ubicación y tu información médica.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      _metric('Hora del SOS', time),
                      Container(
                        width: 1,
                        height: 70,
                        color: AppColors.lineSoft,
                      ),
                      _metric(
                        'Contactos avisados',
                        '${c.contacts.length} de ${c.contacts.length}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Eyebrow('Estado'),
                const SizedBox(height: 14),
                _timeline('SOS recibido', time, true),
                _timeline(
                  'Ubicación enviada',
                  c.properties.isEmpty
                      ? 'Coordenadas GPS'
                      : '${c.properties.first.name} · ${c.properties.first.locality ?? ''}',
                  true,
                ),
                _timeline(
                  'Contactos notificados',
                  c.contacts.map((e) => e.name).join(' · '),
                  true,
                ),
                _timeline(
                  attended
                      ? (resolved ? 'Emergencia resuelta' : 'Equipo atendiendo')
                      : 'Esperando atención',
                  attended
                      ? 'El centro actualizó el estado'
                      : 'El centro ya tiene tu pedido',
                  attended,
                  last: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => launchUrl(Uri.parse('tel:107')),
                  child: const Text('Llamar a emergencias'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => launchUrl(
                    Uri.parse(
                      'sms:?body=Generé un SOS Rural. Mi ubicación fue enviada al centro de emergencias.',
                    ),
                  ),
                  child: const Text('Compartir ubicación'),
                ),
                TextButton(
                  onPressed: c.cancelIncident,
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    'Cancelar: fue una falsa alarma',
                    style: TextStyle(color: AppColors.faint),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _metric(String label, String value) => Expanded(
  child: Padding(
    padding: const EdgeInsets.all(17),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.faint),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  ),
);

Widget _timeline(
  String title,
  String note,
  bool done, {
  bool last = false,
}) => IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 20,
        child: Column(
          children: [
            StatusCircle(done: done),
            if (!last)
              Expanded(
                child: Container(width: 1.5, color: const Color(0xFFE3E3DF)),
              ),
          ],
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: last ? 0 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: done ? AppColors.ink : AppColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                note,
                style: const TextStyle(fontSize: 13, color: AppColors.faint),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);
