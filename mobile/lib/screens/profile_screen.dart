import 'package:flutter/material.dart';
import '../app/app.dart';
import '../app/app_controller.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 34),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFEFEFEC),
                child: Text(
                  c.initials,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${c.user['firstName']} ${c.user['lastName']}',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.3,
                      ),
                    ),
                    Text(
                      c.user['phone'] ?? '',
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _group([
            _item(
              'Información personal',
              onTap: () => _editPersonal(context, c),
            ),
            _item(
              'Información médica',
              note: 'Completa',
              noteColor: AppColors.ok,
              onTap: () => c.go(AppScreen.medical),
            ),
            _item(
              'Contactos de emergencia',
              note: '${c.contacts.length}',
              onTap: () => c.go(AppScreen.contacts),
            ),
          ]),
          const SizedBox(height: 16),
          _group([
            _item('Permisos', note: 'GPS, SMS'),
            _item(
              'Recorrido reciente',
              note: c.trailEnabled ? 'Activado' : 'Desactivado',
              noteColor: c.trailEnabled ? AppColors.ok : AppColors.faint,
              onTap: () => c.go(AppScreen.trail),
            ),
            _item('Notificaciones'),
            _item('Privacidad'),
          ]),
          const SizedBox(height: 16),
          _group([
            _item(
              'Configuración inicial',
              note: '80%',
              onTap: () => c.go(AppScreen.setup),
            ),
          ]),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: c.logout,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.medical),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Future<void> _editPersonal(BuildContext context, dynamic c) async {
    final firstName = TextEditingController(text: c.user['firstName'] ?? '');
    final lastName = TextEditingController(text: c.user['lastName'] ?? '');
    final document = TextEditingController(text: c.user['document'] ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información personal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstName,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lastName,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: document,
                decoration: const InputDecoration(labelText: 'Documento'),
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
    if (ok == true) {
      await c.savePersonal({
        'firstName': firstName.text,
        'lastName': lastName.text,
        'document': document.text,
      });
    }
  }
}

Widget _group(List<Widget> children) => AppCard(
  padding: EdgeInsets.zero,
  child: Column(children: children),
);
Widget _item(
  String label, {
  String? note,
  Color noteColor = AppColors.faint,
  VoidCallback? onTap,
}) => InkWell(
  onTap: onTap,
  child: Container(
    constraints: const BoxConstraints(minHeight: 53),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.lineSoft)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        if (note != null) ...[
          Text(note, style: TextStyle(fontSize: 14, color: noteColor)),
          const SizedBox(width: 8),
        ],
        const Text(
          '›',
          style: TextStyle(fontSize: 22, color: Color(0xFFC9C9C5)),
        ),
      ],
    ),
  ),
);
