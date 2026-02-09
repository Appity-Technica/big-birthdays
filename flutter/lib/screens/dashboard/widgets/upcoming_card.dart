import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../models/person.dart';
import '../../../widgets/initials_avatar.dart';
import '../../../widgets/tag_chip.dart';

class UpcomingCard extends StatelessWidget {
  final Person person;
  final int index;
  final VoidCallback? onTap;

  const UpcomingCard({
    super.key,
    required this.person,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final days = daysUntilBirthday(person.dateOfBirth);
    final age = getUpcomingAge(person.dateOfBirth);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lav(context), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(
                  name: person.name,
                  size: 40,
                  colorIndex: index,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.fg(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formatDate(person.dateOfBirth),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.fg(context).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (age != null)
                  TagChip(label: 'Turning $age', color: AppColors.orange),
                TagChip(
                  label: person.relationship.displayLabel,
                  color: AppColors.teal,
                ),
                TagChip(
                  label: days == 1 ? 'Tomorrow' : 'In $days days',
                  color: AppColors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
