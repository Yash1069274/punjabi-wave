import 'package:flutter/material.dart';

import '../../core/theme/neon_theme.dart';

class GestureEqualizer extends StatefulWidget {
  const GestureEqualizer({super.key});

  @override
  State<GestureEqualizer> createState() => _GestureEqualizerState();
}

class _GestureEqualizerState extends State<GestureEqualizer> {
  final gains = List<double>.filled(7, 0.45);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final box = context.findRenderObject()! as RenderBox;
        final local = box.globalToLocal(details.globalPosition);
        final band = (local.dx / (box.size.width / gains.length)).floor().clamp(0, gains.length - 1);
        setState(() => gains[band] = (1 - local.dy / box.size.height).clamp(0.0, 1.0));
      },
      child: CustomPaint(
        painter: _EqualizerPainter(gains),
        child: const SizedBox(height: 116, width: double.infinity),
      ),
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  _EqualizerPainter(this.gains);
  final List<double> gains;

  @override
  void paint(Canvas canvas, Size size) {
    final bandWidth = size.width / gains.length;
    for (var i = 0; i < gains.length; i++) {
      final x = i * bandWidth + bandWidth * 0.2;
      final h = size.height * gains[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, bandWidth * 0.58, h),
        const Radius.circular(999),
      );
      final paint = Paint()
        ..shader = const LinearGradient(
          colors: [NeonTheme.cyberBlue, NeonTheme.plasmaPink],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EqualizerPainter oldDelegate) => oldDelegate.gains != gains;
}
