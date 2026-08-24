import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class TemplatesTab extends StatelessWidget {
  final AppLocalizations l;
  const TemplatesTab({super.key, required this.l});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = [l.get('trending'), l.get('new_label'), 'Vlog', 'Travel', 'Food', 'Music'];

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  l.get('templates_title'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(Icons.search_rounded, color: isDark ? Colors.white70 : Colors.black54),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selected
                        ? const Color(0xFF00C2FF)
                        : (isDark ? const Color(0xFF252538) : const Color(0xFFF0F0F5)),
                  ),
                  child: Text(
                    categories[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected ? Colors.white : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: 12,
              itemBuilder: (context, i) {
                final colors = [
                  [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                  [const Color(0xFFF093FB), const Color(0xFFF5576C)],
                  [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
                  [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
                  [const Color(0xFFFA709A), const Color(0xFFFEE140)],
                  [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
                ];
                final colorPair = colors[i % colors.length];
                return GestureDetector(
                  onTap: () {},
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colorPair,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_fill_rounded,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Text(
                              'Template ${i + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (i < 3)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l.get('new_label').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
