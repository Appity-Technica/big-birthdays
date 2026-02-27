import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/utils.dart';

class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;
  final int? colorIndex;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final initials = getInitials(name);
    final idx = colorIndex ?? name.hashCode;
    final color = AppColors.accentForIndex(idx);

    return Semantics(
      label: 'Avatar for $name',
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: GoogleFonts.baloo2(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
