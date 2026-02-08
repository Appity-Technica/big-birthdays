import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';

class StatsRow extends StatelessWidget {
  final int totalCount;
  final int todayCount;
  final int? nextDays;

  const StatsRow({
    super.key,
    required this.totalCount,
    required this.todayCount,
    this.nextDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stat('Tracking', '$totalCount', AppColors.purple),
        const SizedBox(width: 12),
        _stat('Today', '$todayCount', AppColors.pink),
        const SizedBox(width: 12),
        _stat(
          'Next Up',
          nextDays != null ? '$nextDays days' : '-',
          AppColors.teal,
        ),
      ],
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.baloo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
