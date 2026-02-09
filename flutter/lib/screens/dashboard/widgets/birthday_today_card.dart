import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../models/person.dart';
import '../../../widgets/initials_avatar.dart';
import '../../../widgets/tag_chip.dart';

class BirthdayTodayCard extends StatelessWidget {
  final Person person;
  final VoidCallback? onTap;

  const BirthdayTodayCard({super.key, required this.person, this.onTap});

  @override
  Widget build(BuildContext context) {
    final age = getUpcomingAge(person.dateOfBirth);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.purple, AppColors.pink, AppColors.coral],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            children: [
              InitialsAvatar(name: person.name, size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: GoogleFonts.baloo2(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (age != null)
                          TagChip(
                            label: 'Turning $age',
                            color: AppColors.pink,
                          ),
                        TagChip(
                          label: person.relationship.displayLabel,
                          color: AppColors.teal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Text('🎂', style: TextStyle(fontSize: 32)),
            ],
          ),
        ),
      ),
    );
  }
}
