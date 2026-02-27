import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/analytics.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/people_provider.dart';
import '../../repositories/export_repository.dart';
import '../../widgets/initials_avatar.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/tag_chip.dart';
import 'widgets/star_rating.dart';

class PersonDetailScreen extends ConsumerWidget {
  final String personId;
  const PersonDetailScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(personByIdProvider(personId));
    if (person == null) {
      return const Scaffold(body: LoadingSpinner());
    }

    final age = getCurrentAge(person.dateOfBirth);
    final upcomingAge = getUpcomingAge(person.dateOfBirth);
    final days = daysUntilBirthday(person.dateOfBirth);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Analytics.logSharePerson();
              final repo = ExportRepository();
              final summary = repo.generatePersonSummary(person);
              Share.share(summary);
            },
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: AppColors.pink),
            onPressed: () => context.push('/people/${person.id}/gifts'),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/people/${person.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.coral),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Center(
            child: Hero(
              tag: 'avatar-${person.id}',
              child: InitialsAvatar(name: person.name, size: 80),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              person.name,
              style: GoogleFonts.baloo2(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
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
                      label: 'Turning $upcomingAge', color: AppColors.orange),
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
          const SizedBox(height: 4),
          Center(
            child: Text(
              formatDate(person.dateOfBirth),
              style: TextStyle(
                  color: AppColors.fg(context).withValues(alpha: 0.5),
                  fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),

          // Connection
          if (person.connectedThrough != null &&
              person.connectedThrough!.isNotEmpty)
            _section(context,
              'Connection',
              color: AppColors.lav(context),
              child: Wrap(
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
            ),

          // Parties
          if (person.parties != null && person.parties!.isNotEmpty)
            _section(context,
              'Parties',
              color: AppColors.mn(context),
              child: Column(
                children: person.parties!
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TagChip(
                                  label: '${p.year}', color: AppColors.teal),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (p.date != null)
                                      Text(p.date!,
                                          style:
                                              const TextStyle(fontSize: 13)),
                                    if (p.invitedNames != null &&
                                        p.invitedNames!.isNotEmpty)
                                      Text(
                                        'Invited: ${p.invitedNames!.join(', ')}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.fg(context)
                                                .withValues(alpha: 0.6)),
                                      ),
                                    if (p.notes != null)
                                      Text(p.notes!,
                                          style:
                                              const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),

          // Notes
          if (person.notes != null && person.notes!.isNotEmpty)
            _section(context,
              'Notes',
              color: AppColors.lav(context),
              child:
                  Text(person.notes!, style: const TextStyle(fontSize: 13)),
            ),

          // Interests
          if (person.interests != null && person.interests!.isNotEmpty)
            _section(context,
              'Interests',
              color: AppColors.mn(context),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: person.interests!
                    .map((i) => TagChip(label: i, color: AppColors.teal))
                    .toList(),
              ),
            ),

          // Gift Ideas
          if (person.giftIdeas != null && person.giftIdeas!.isNotEmpty)
            _section(context,
              'Gift Ideas',
              color: AppColors.yellowLight,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: person.giftIdeas!
                    .map((i) => TagChip(label: i, color: AppColors.orange))
                    .toList(),
              ),
            ),

          // Past Gifts
          if (person.pastGifts != null && person.pastGifts!.isNotEmpty)
            _section(context,
              'Past Gifts',
              color: AppColors.pinkLight,
              child: Column(
                children: person.pastGifts!
                    .map((g) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              TagChip(
                                  label: '${g.year}', color: AppColors.pink),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(g.description,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                              if (g.rating != null && g.rating! > 0)
                                StarRatingDisplay(
                                    rating: g.rating!, size: 14),
                              if (g.url != null && g.url!.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.open_in_new,
                                      size: 16),
                                  onPressed: () {
                                    final uri = Uri.parse(g.url!);
                                    if (uri.scheme == 'http' || uri.scheme == 'https') {
                                      launchUrl(uri);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Invalid URL: only http and https links are supported.')),
                                      );
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title,
      {required Color color, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.baloo2(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.fg(context),
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person'),
        content:
            const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.lightImpact();
      Analytics.logDeletePerson();
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        await ref
            .read(peopleRepositoryProvider)
            .deletePerson(user.uid, personId);
        if (context.mounted) context.pop();
      }
    }
  }
}
