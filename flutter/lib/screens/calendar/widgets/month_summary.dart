import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../models/person.dart';
import '../../../widgets/initials_avatar.dart';

class MonthSummary extends StatelessWidget {
  final List<Person> people;
  final String monthLabel;

  const MonthSummary({
    super.key,
    required this.people,
    required this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No birthdays in $monthLabel',
            style: TextStyle(
              color: AppColors.foreground.withValues(alpha: 0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '$monthLabel Birthdays (${people.length})',
            style: GoogleFonts.baloo2(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.purple,
            ),
          ),
        ),
        ...people.map((person) {
          final dob = parseDob(person.dateOfBirth);
          final age = getUpcomingAge(person.dateOfBirth);
          return ListTile(
            leading: InitialsAvatar(name: person.name, size: 40),
            title: Text(
              person.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              '${dob.day} $monthLabel${age != null ? ' · Turning $age' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.foreground.withValues(alpha: 0.5),
              ),
            ),
            onTap: () => context.push('/people/${person.id}'),
          );
        }),
      ],
    );
  }
}
