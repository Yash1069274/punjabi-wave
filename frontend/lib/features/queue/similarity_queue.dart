import 'package:flutter/material.dart';

import '../../core/theme/neon_theme.dart';

class SimilarityQueue extends StatelessWidget {
  const SimilarityQueue({required this.titles, super.key});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: NeonTheme.cyberBlue.withOpacity(0.22)),
          ),
          child: Text(
            titles[index],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
