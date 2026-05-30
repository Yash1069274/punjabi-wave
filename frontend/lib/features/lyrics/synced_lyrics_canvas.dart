import 'package:flutter/material.dart';

import '../../core/theme/neon_theme.dart';

class SyncedLyricsCanvas extends StatelessWidget {
  const SyncedLyricsCanvas({required this.lines, required this.activeIndex, super.key});

  final List<String> lines;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ShaderMask(
        shaderCallback: (rect) => const LinearGradient(
          colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
          stops: [0, 0.18, 0.82, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect),
        blendMode: BlendMode.dstIn,
        child: ListWheelScrollView.useDelegate(
          itemExtent: 44,
          perspective: 0.002,
          physics: const NeverScrollableScrollPhysics(),
          controller: FixedExtentScrollController(initialItem: activeIndex),
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: lines.length,
            builder: (context, index) {
              final active = index == activeIndex;
              return AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                style: TextStyle(
                  color: active ? NeonTheme.cyberBlue : Colors.white54,
                  fontSize: active ? 22 : 16,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  shadows: active ? const [Shadow(color: NeonTheme.cyberBlue, blurRadius: 20)] : null,
                ),
                child: Center(child: Text(lines[index], textAlign: TextAlign.center)),
              );
            },
          ),
        ),
      ),
    );
  }
}
