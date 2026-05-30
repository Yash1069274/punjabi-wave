import 'dart:math' as math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/neon_theme.dart';

class FluidArtOrb extends StatefulWidget {
  const FluidArtOrb({
    required this.artworkUrl,
    required this.artistPortraitUrl,
    super.key,
  });

  final String artworkUrl;
  final String artistPortraitUrl;

  @override
  State<FluidArtOrb> createState() => _FluidArtOrbState();
}

class _FluidArtOrbState extends State<FluidArtOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * math.pi * 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(math.sin(angle) * 0.55)
            ..rotateX(math.cos(angle * 0.7) * 0.18),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(330),
                painter: _NebulaPainter(t: _controller.value),
              ),
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: 245,
                    height: 245,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.3),
                      boxShadow: const [
                        BoxShadow(color: NeonTheme.cyberBlue, blurRadius: 38, spreadRadius: -10),
                        BoxShadow(color: NeonTheme.plasmaPink, blurRadius: 45, spreadRadius: -16),
                      ],
                    ),
                    child: ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                        colors: [Colors.white, Colors.white70, Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(rect),
                      child: CachedNetworkImage(
                        imageUrl: widget.artworkUrl.isNotEmpty ? widget.artworkUrl : widget.artistPortraitUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              ...List.generate(8, (index) {
                final phase = angle + index * math.pi / 4;
                return Transform.translate(
                  offset: Offset(math.cos(phase) * 155, math.sin(phase * 1.3) * 85),
                  child: Container(
                    width: 18 + index * 2,
                    height: 18 + index * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(NeonTheme.cyberBlue, NeonTheme.plasmaPink, index / 7)!.withOpacity(0.58),
                      boxShadow: [BoxShadow(color: NeonTheme.cyberBlue.withOpacity(0.45), blurRadius: 24)],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _NebulaPainter extends CustomPainter {
  _NebulaPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (var i = 0; i < 9; i++) {
      final progress = (i / 9 + t) % 1;
      paint.color = Color.lerp(NeonTheme.laserViolet, NeonTheme.cyberBlue, progress)!.withOpacity(1 - progress);
      canvas.drawCircle(center, radius * (0.25 + progress * 0.75), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter oldDelegate) => oldDelegate.t != t;
}
