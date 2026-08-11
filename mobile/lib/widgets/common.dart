import 'package:flutter/material.dart';
import '../core/theme.dart';

class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          height: 1.1,
          fontWeight: FontWeight.w600,
          letterSpacing: -.6,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 8),
        Text(
          subtitle!,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.muted,
          ),
        ),
      ],
    ],
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = AppColors.faint});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: .8,
      color: color,
    ),
  );
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: AppColors.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class DashedAction extends StatelessWidget {
  const DashedAction({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFD8D8D4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label),
    ),
  );
}

class StatusCircle extends StatelessWidget {
  const StatusCircle({super.key, this.done = false, this.warning = false});
  final bool done, warning;
  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: done
          ? AppColors.ok
          : warning
          ? const Color(0xFFF4EDE4)
          : Colors.transparent,
      border: done || warning
          ? null
          : Border.all(color: AppColors.lineStrong, width: 1.5),
    ),
    alignment: Alignment.center,
    child: done
        ? const Text(
            '✓',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          )
        : warning
        ? const Text(
            '!',
            style: TextStyle(
              color: AppColors.fire,
              fontWeight: FontWeight.w700,
            ),
          )
        : null,
  );
}

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    this.height = 112,
    this.label = 'Mapa rural',
  });
  final double height;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    color: const Color(0xFFE9E9E5),
    child: CustomPaint(
      painter: _RoadPainter(),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ),
      ),
    ),
  );
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(-10, s.height * .75)
      ..cubicTo(
        s.width * .25,
        s.height * .9,
        s.width * .45,
        s.height * .15,
        s.width + 10,
        s.height * .32,
      );
    c.drawPath(path, p);
    p
      ..color = AppColors.police
      ..strokeWidth = 3;
    c.drawPath(path, p);
    c.drawCircle(
      Offset(s.width * .72, s.height * .28),
      7,
      Paint()..color = AppColors.ok,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
