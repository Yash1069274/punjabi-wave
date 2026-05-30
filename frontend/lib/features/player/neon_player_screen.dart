import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/neon_theme.dart';
import '../equalizer/gesture_equalizer.dart';
import '../lyrics/synced_lyrics_canvas.dart';
import '../queue/similarity_queue.dart';
import 'models/player_track.dart';
import 'widgets/fluid_art_orb.dart';

class NeonPlayerScreen extends StatelessWidget {
  const NeonPlayerScreen({super.key});

  static const demo = PlayerTrack(
    id: 'demo',
    title: 'Verified Wave',
    artistName: 'Auto-Matched Artist',
    albumTitle: 'MusicBrainz Certified Album',
    audioUri: 'http://localhost:8080/audio/demo.flac',
    artworkUrl: 'https://api.dicebear.com/9.x/shapes/svg?seed=punjabi-wave-album',
    artistPortraitUrl: 'https://api.dicebear.com/9.x/personas/svg?seed=punjabi-wave-artist',
    isLossless: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AuroraBackdrop(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              child: Column(
                children: [
                  const _OrbitalHeader(),
                  const Spacer(),
                  const FluidArtOrb(
                    artworkUrl: demo.artworkUrl,
                    artistPortraitUrl: demo.artistPortraitUrl,
                  ),
                  const SizedBox(height: 18),
                  Text(demo.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                  Text('${demo.artistName} • ${demo.albumTitle}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 18),
                  const _GlassPanel(child: GestureEqualizer()),
                  const SizedBox(height: 14),
                  const _GlassPanel(
                    child: SyncedLyricsCanvas(
                      activeIndex: 1,
                      lines: ['ਚੰਦ ਵਰਗੀ ਲੋਅ', 'Neon dhol in motion', 'Bassline flows like water', 'ਸੁਰਾਂ ਦਾ spatial wave'],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const SimilarityQueue(titles: ['Acoustic neighbor #1', 'Same tempo glow', 'Folk bass twin', 'Late-night sufi mix']),
                  const Spacer(),
                  const _TransportControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitalHeader extends StatelessWidget {
  const _OrbitalHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('ਪੰਜਾਬੀ WAVE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: NeonTheme.cyberBlue.withOpacity(0.4)),
          ),
          child: const Text('LOSSLESS FLAC', style: TextStyle(color: NeonTheme.cyberBlue, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class _TransportControls extends StatelessWidget {
  const _TransportControls();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Icon(Icons.replay_10_rounded, size: 32),
        _PlayButton(),
        Icon(Icons.forward_10_rounded, size: 32),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      width: 76,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [NeonTheme.cyberBlue, NeonTheme.plasmaPink]),
        boxShadow: [BoxShadow(color: NeonTheme.plasmaPink, blurRadius: 30)],
      ),
      child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 44),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NeonTheme.glass,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AuroraBackdrop extends StatelessWidget {
  const _AuroraBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.4,
          colors: [Color(0x663EFFF6), Color(0x332F005F), NeonTheme.obsidian],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
