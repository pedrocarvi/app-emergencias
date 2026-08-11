import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/app.dart';
import '../app/app_controller.dart';
import '../core/theme.dart';
import '../models/domain.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Necesitás ayuda?',
                        style: TextStyle(
                          fontSize: 29,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -.6,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Mantené presionado 3 segundos.',
                        style: TextStyle(fontSize: 15, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => c.go(AppScreen.profile),
                  borderRadius: BorderRadius.circular(99),
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFFEFEFEC),
                    child: Text(
                      c.initials,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SosHoldButton(
              type: IncidentType.medical,
              height: 150,
              wide: true,
              onComplete: c.sendSos,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SosHoldButton(
                    type: IncidentType.fire,
                    height: 150,
                    onComplete: c.sendSos,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SosHoldButton(
                    type: IncidentType.police,
                    height: 150,
                    onComplete: c.sendSos,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (c.errorMessage != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.location_off,
                    color: AppColors.fire,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.errorMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.fire,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.online ? AppColors.ok : AppColors.fire,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        c.online
                            ? 'Todo listo para una emergencia'
                            : 'Conectividad limitada',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip('GPS activo'),
                      _chip(c.online ? 'Con conexión' : 'Sin conexión'),
                      _chip(
                        c.trailEnabled
                            ? 'Recorrido activo'
                            : 'Recorrido desactivado',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.chip,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
    ),
  );
}

class SosHoldButton extends StatefulWidget {
  const SosHoldButton({
    super.key,
    required this.type,
    required this.height,
    required this.onComplete,
    this.wide = false,
  });
  final IncidentType type;
  final double height;
  final bool wide;
  final ValueChanged<IncidentType> onComplete;
  @override
  State<SosHoldButton> createState() => _SosHoldButtonState();
}

class _SosHoldButtonState extends State<SosHoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController progress = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  bool holding = false, tick1 = false, tick2 = false;
  @override
  void initState() {
    super.initState();
    progress.addListener(() {
      if (progress.value >= .33 && !tick1) {
        tick1 = true;
        HapticFeedback.selectionClick();
      }
      if (progress.value >= .66 && !tick2) {
        tick2 = true;
        HapticFeedback.selectionClick();
      }
      setState(() {});
    });
    progress.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        holding = false;
        HapticFeedback.heavyImpact();
        widget.onComplete(widget.type);
        progress.reset();
      }
    });
  }

  void start(PointerDownEvent _) {
    tick1 = tick2 = false;
    holding = true;
    progress.forward(from: 0);
    setState(() {});
  }

  void stop(PointerEvent _) {
    if (progress.isAnimating) {
      progress.stop();
      progress.reset();
      holding = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = incidentColor(widget.type);
    return Listener(
      onPointerDown: start,
      onPointerUp: stop,
      onPointerCancel: stop,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .4),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.value,
                  child: Container(color: Colors.black.withValues(alpha: .16)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(widget.wide ? 22 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: widget.wide ? 40 : 38,
                          height: widget.wide ? 40 : 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            switch (widget.type) {
                              IncidentType.medical => Icons.add,
                              IncidentType.fire =>
                                Icons.local_fire_department_rounded,
                              IncidentType.police => Icons.shield_rounded,
                            },
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        if (widget.wide)
                          Text(
                            holding ? 'Seguí presionando…' : 'Mantené 3 s',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: .85),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      widget.wide
                          ? widget.type.label
                          : 'SOS\n${widget.type.short}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.wide ? 26 : 20,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
