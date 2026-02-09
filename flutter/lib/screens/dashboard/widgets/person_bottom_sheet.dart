import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';
import '../../../models/person.dart';
import '../../../widgets/initials_avatar.dart';
import '../../../widgets/tag_chip.dart';
import '../../people/widgets/star_rating.dart';

class PersonBottomSheet extends StatelessWidget {
  final Person person;

  const PersonBottomSheet({super.key, required this.person});

  static void show(BuildContext context, Person person) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PersonBottomSheet(person: person),
    );
  }

  @override
  Widget build(BuildContext context) {
    final age = getCurrentAge(person.dateOfBirth);
    final upcomingAge = getUpcomingAge(person.dateOfBirth);
    final days = daysUntilBirthday(person.dateOfBirth);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lav(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Center(child: InitialsAvatar(name: person.name, size: 72)),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  person.name,
                  style: GoogleFonts.baloo2(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.purple,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    if (age != null)
                      TagChip(label: 'Age $age', color: AppColors.pink),
                    TagChip(
                      label: person.relationship.displayLabel,
                      color: AppColors.teal,
                    ),
                    if (upcomingAge != null)
                      TagChip(
                        label: 'Turning $upcomingAge',
                        color: AppColors.orange,
                      ),
                    TagChip(
                      label: days == 0
                          ? 'Today!'
                          : days == 1
                              ? 'Tomorrow'
                              : 'In $days days',
                      color: AppColors.purple,
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    formatDate(person.dateOfBirth),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.fg(context).withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Connection
              if (person.connectedThrough != null &&
                  person.connectedThrough!.isNotEmpty) ...[
                _sectionTitle(context, 'Connection'),
                Wrap(
                  spacing: 6,
                  children: [
                    TagChip(
                      label: 'Via ${person.connectedThrough}',
                      color: AppColors.purpleLight,
                    ),
                    if (person.knownFrom != null)
                      TagChip(
                        label: person.knownFrom!.displayLabel,
                        color: AppColors.teal,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              if (person.notes != null && person.notes!.isNotEmpty) ...[
                _sectionTitle(context, 'Notes'),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lav(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(person.notes!,
                      style: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],

              // Interests
              if (person.interests != null &&
                  person.interests!.isNotEmpty) ...[
                _sectionTitle(context, 'Interests'),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: person.interests!
                      .map((i) => TagChip(label: i, color: AppColors.teal))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Gift Ideas
              if (person.giftIdeas != null &&
                  person.giftIdeas!.isNotEmpty) ...[
                _sectionTitle(context, 'Gift Ideas'),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: person.giftIdeas!
                      .map(
                          (i) => TagChip(label: i, color: AppColors.orange))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Past Gifts
              if (person.pastGifts != null &&
                  person.pastGifts!.isNotEmpty) ...[
                _sectionTitle(context, 'Past Gifts'),
                ...person.pastGifts!.map((g) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.pink.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.pink.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            TagChip(
                              label: '${g.year}',
                              color: AppColors.pink,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(g.description,
                                  style: const TextStyle(fontSize: 13)),
                            ),
                            if (g.rating != null && g.rating! > 0)
                              StarRatingDisplay(
                                  rating: g.rating!, size: 14),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
              ],

              // Buy a Gift
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/people/${person.id}/gifts');
                  },
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('Buy a Gift'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/people/${person.id}');
                      },
                      child: const Text('View Profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/people/${person.id}/edit');
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.baloo2(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.fg(context),
        ),
      ),
    );
  }
}
