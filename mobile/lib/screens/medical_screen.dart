import 'package:flutter/material.dart';
import '../app/app.dart';
import '../app/app_controller.dart';
import '../core/theme.dart';
import '../models/domain.dart';
import '../widgets/common.dart';

class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});
  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  bool loaded = false;
  late MedicalProfile value;
  late TextEditingController allergies, medications, cardio, notes;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      value = AppScope.of(context).medicalProfile;
      allergies = TextEditingController(text: value.allergies);
      medications = TextEditingController(text: value.medications);
      cardio = TextEditingController(text: value.cardiovascularConditions);
      notes = TextEditingController(text: value.notes);
      loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
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
              'Información médica',
              subtitle:
                  'Esta información podrá ser visualizada durante una emergencia.',
            ),
            const SizedBox(height: 26),
            const _Label('Grupo sanguíneo'),
            const SizedBox(height: 10),
            Row(
              children: ['0', 'A', 'B', 'AB']
                  .map(
                    (e) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: e != 'AB' ? 8 : 0),
                        child: _Choice(
                          label: e,
                          selected: value.bloodType == e,
                          onTap: () => setState(() => value.bloodType = e),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: ['+', '-']
                  .map(
                    (e) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: e == '+' ? 8 : 0),
                        child: _Choice(
                          label: 'Factor $e',
                          selected: value.bloodFactor == e,
                          onTap: () => setState(() => value.bloodFactor = e),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            _LabelField('Alergias', allergies),
            const SizedBox(height: 14),
            _LabelField('Medicación habitual', medications, maxLines: 3),
            const SizedBox(height: 22),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _toggle(
                    'Diabetes',
                    value.hasDiabetes,
                    (v) => setState(() => value.hasDiabetes = v),
                  ),
                  _toggle(
                    'Epilepsia',
                    value.hasEpilepsy,
                    (v) => setState(() => value.hasEpilepsy = v),
                  ),
                  _toggle(
                    'Condición cardiovascular',
                    value.cardiovascularConditions.isNotEmpty,
                    (v) => setState(
                      () => value.cardiovascularConditions = v
                          ? cardio.text.isEmpty
                                ? 'Declarada'
                                : cardio.text
                          : '',
                    ),
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _LabelField('Detalle cardiovascular', cardio),
            const SizedBox(height: 14),
            _LabelField('Observaciones', notes, maxLines: 4),
            if (c.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  c.errorMessage!,
                  style: const TextStyle(color: AppColors.medical),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: c.busy
                  ? null
                  : () {
                      value.allergies = allergies.text;
                      value.medications = medications.text;
                      value.cardiovascularConditions = cardio.text;
                      value.notes = notes.text;
                      c.saveMedical(value);
                    },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.faint,
    ),
  );
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      height: 48,
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? AppColors.ink : AppColors.line),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? Colors.white : AppColors.muted,
        ),
      ),
    ),
  );
}

class _LabelField extends StatelessWidget {
  const _LabelField(this.label, this.controller, {this.maxLines = 1});
  final String label;
  final TextEditingController controller;
  final int maxLines;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Label(label),
      const SizedBox(height: 7),
      TextField(controller: controller, maxLines: maxLines),
    ],
  );
}

Widget _toggle(
  String label,
  bool value,
  ValueChanged<bool> onChanged, {
  bool last = false,
}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
  decoration: BoxDecoration(
    border: last
        ? null
        : const Border(bottom: BorderSide(color: AppColors.lineSoft)),
  ),
  child: Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.ok,
      ),
    ],
  ),
);
