import 'dart:io';

import 'package:flutter/material.dart';

class ProjectThumb extends StatelessWidget {
  final String? path;
  final String projectType;
  final double width;
  final double height;
  final double radius;

  const ProjectThumb({
    super.key,
    required this.path,
    required this.projectType,
    this.width = 70,
    this.height = 80,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final icon =
        projectType == 'photo' ? Icons.photo_rounded : Icons.videocam_rounded;
    Widget child;
    if (path != null) {
      final file = File(path!);
      if (file.existsSync()) {
        child = Image.file(
          file,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(icon),
        );
      } else {
        child = _fallback(icon);
      }
    } else {
      child = _fallback(icon);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }

  Widget _fallback(IconData icon) {
    return ColoredBox(
      color: const Color(0xFF00C2FF).withValues(alpha: 0.18),
      child: Center(
        child: Icon(icon, color: const Color(0xFF00C2FF), size: width * 0.4),
      ),
    );
  }
}
