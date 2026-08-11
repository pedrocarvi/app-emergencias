import 'package:flutter/material.dart';
import '../app/app.dart';
import '../core/theme.dart';
import '../models/domain.dart';
import '../widgets/common.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});
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
            const ScreenTitle(
              'Contactos',
              subtitle:
                  'Al generar un SOS reciben un SMS con tu ubicación y el tipo de emergencia.',
            ),
            const SizedBox(height: 24),
            ...c.contacts.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ContactCard(e),
              ),
            ),
            const SizedBox(height: 10),
            DashedAction(
              label: 'Agregar contacto',
              onTap: () => _add(context, c),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, dynamic c) async {
    final name = TextEditingController(),
        phone = TextEditingController(),
        relationship = TextEditingController(text: 'Familiar');
    var notifyMedical = true, notifyFire = true, notifyPolice = true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo contacto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: relationship,
                  decoration: const InputDecoration(labelText: 'Relación'),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('SOS Médico'),
                  value: notifyMedical,
                  onChanged: (value) =>
                      setDialogState(() => notifyMedical = value ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('SOS Bomberos'),
                  value: notifyFire,
                  onChanged: (value) =>
                      setDialogState(() => notifyFire = value ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('SOS Policía'),
                  value: notifyPolice,
                  onChanged: (value) =>
                      setDialogState(() => notifyPolice = value ?? false),
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
      ),
    );
    if (ok == true && name.text.isNotEmpty) {
      await c.api.createContact({
        'name': name.text,
        'phone': phone.text,
        'relationship': relationship.text,
        'notifyMedical': notifyMedical,
        'notifyFire': notifyFire,
        'notifyPolice': notifyPolice,
      });
      await c.refresh();
    }
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard(this.contact);
  final EmergencyContact contact;
  @override
  Widget build(BuildContext context) {
    final initials = contact.name.split(' ').take(2).map((e) => e[0]).join();
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.chip,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${contact.relationship} · ${contact.phone}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.muted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              if (contact.notifyMedical)
                _tag('Médico', AppColors.medical, AppColors.medicalSoft),
              if (contact.notifyFire)
                _tag('Bomberos', AppColors.fire, AppColors.fireSoft),
              if (contact.notifyPolice)
                _tag('Policía', AppColors.police, AppColors.policeSoft),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String t, Color c, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      t,
      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c),
    ),
  );
}
