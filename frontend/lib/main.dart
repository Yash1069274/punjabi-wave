import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/neon_theme.dart';
import 'features/player/neon_player_screen.dart';

void main() => runApp(const ProviderScope(child: PunjabiWaveApp()));

class PunjabiWaveApp extends StatelessWidget {
  const PunjabiWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Punjabi Wave',
      theme: NeonTheme.dark(),
      home: const NeonPlayerScreen(),
    );
  }
}
