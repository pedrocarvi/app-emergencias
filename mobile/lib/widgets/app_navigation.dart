import 'package:flutter/material.dart';
import '../app/app.dart';
import '../app/app_controller.dart';
import '../core/theme.dart';

class AppNavigation extends StatelessWidget {
  const AppNavigation({super.key, required this.current});
  final AppScreen current;
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final items = [
      (Icons.home_rounded, 'Inicio', AppScreen.home),
      (Icons.crop_square_rounded, 'Campos', AppScreen.fields),
      (Icons.contacts_outlined, 'Contactos', AppScreen.contacts),
      (Icons.person_rounded, 'Perfil', AppScreen.profile),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.lineSoft)),
      ),
      padding: EdgeInsets.only(
        top: 7,
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        children: items.map((e) {
          final active = e.$3 == current;
          return Expanded(
            child: InkWell(
              onTap: () => c.go(e.$3),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      e.$1,
                      size: 21,
                      color: active ? AppColors.ink : const Color(0xFFB4B5B8),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.$2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active ? AppColors.ink : const Color(0xFFB4B5B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
