import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/person.dart';
import '../../providers/auth_provider.dart';
import '../../providers/people_provider.dart';
import '../../providers/gift_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/initials_avatar.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/tag_chip.dart';
import '../people/widgets/star_rating.dart';

class GiftReviewScreen extends ConsumerStatefulWidget {
  final String personId;
  const GiftReviewScreen({super.key, required this.personId});

  @override
  ConsumerState<GiftReviewScreen> createState() => _GiftReviewScreenState();
}

class _GiftReviewScreenState extends ConsumerState<GiftReviewScreen> {
  final _ageController = TextEditingController();
  int? _enteredAge;
  bool _yearSaved = false;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  /// Calculate the birth year from an entered age and the person's birthday.
  int _calcBirthYear(int age, String dateOfBirth) {
    final now = DateTime.now();
    final dob = parseDob(dateOfBirth);
    // If their birthday hasn't happened yet this year, they were born age+1 years ago
    final hadBirthdayThisYear = now.month > dob.month ||
        (now.month == dob.month && now.day >= dob.day);
    return hadBirthdayThisYear ? now.year - age : now.year - age - 1;
  }

  Future<void> _saveBirthYear(int birthYear) async {
    final person = ref.read(personByIdProvider(widget.personId));
    if (person == null) return;
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final dob = parseDob(person.dateOfBirth);
    final newDob = buildDob(birthYear, dob.month, dob.day);

    await ref
        .read(peopleRepositoryProvider)
        .updatePerson(user.uid, person.id, {'dateOfBirth': newDob});

    if (mounted) {
      setState(() => _yearSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Birth year ($birthYear) saved to ${person.name}\'s profile'),
          backgroundColor: AppColors.teal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final person = ref.watch(personByIdProvider(widget.personId));
    if (person == null) {
      return const Scaffold(body: LoadingSpinner());
    }

    final knownAge = getCurrentAge(person.dateOfBirth);
    final yearIsKnown = hasKnownYear(person.dateOfBirth);
    final effectiveAge = knownAge ?? _enteredAge;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Ideas',
            style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.yellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.yellow.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: AppColors.orange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'The more details you add, the better the gift suggestions will be!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fg(context).withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Center(child: InitialsAvatar(name: person.name, size: 64)),
          const SizedBox(height: 10),
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
          const SizedBox(height: 6),
          Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                if (effectiveAge != null)
                  TagChip(label: 'Age $effectiveAge', color: AppColors.pink),
                TagChip(
                  label: person.relationship.displayLabel,
                  color: AppColors.teal,
                ),
              ],
            ),
          ),

          // Age input when year is unknown
          if (!yearIsKnown && _enteredAge == null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.pink.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.pink.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake_outlined,
                      color: AppColors.pink.withValues(alpha: 0.6),
                      size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Age unknown — enter it for better suggestions:',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.fg(context).withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 56,
                    height: 36,
                    child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Age',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppColors.fg(context).withValues(alpha: 0.3),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppColors.pink.withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppColors.pink.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.pink),
                        ),
                      ),
                      onSubmitted: (value) {
                        final age = int.tryParse(value);
                        if (age != null && age > 0 && age < 150) {
                          setState(() => _enteredAge = age);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        final age = int.tryParse(_ageController.text);
                        if (age != null && age > 0 && age < 150) {
                          setState(() => _enteredAge = age);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Set'),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Save birth year prompt
          if (!yearIsKnown && _enteredAge != null && !_yearSaved) ...[
            const SizedBox(height: 8),
            _buildSaveYearPrompt(person.dateOfBirth),
          ],

          const SizedBox(height: 20),

          // Interests
          _section(
            'Interests',
            color: AppColors.mn(context),
            hasData: person.interests != null && person.interests!.isNotEmpty,
            child: person.interests != null && person.interests!.isNotEmpty
                ? Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: person.interests!
                        .map((i) => TagChip(label: i, color: AppColors.teal))
                        .toList(),
                  )
                : null,
          ),

          // Past Gifts
          _section(
            'Past Gifts',
            color: AppColors.pinkLight,
            hasData:
                person.pastGifts != null && person.pastGifts!.isNotEmpty,
            child: person.pastGifts != null && person.pastGifts!.isNotEmpty
                ? Column(
                    children: person.pastGifts!
                        .map((g) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
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
                                    StarRatingDisplay(rating: g.rating!, size: 14),
                                ],
                              ),
                            ))
                        .toList(),
                  )
                : null,
          ),

          // Notes
          _section(
            'Notes',
            color: AppColors.lav(context),
            hasData: person.notes != null && person.notes!.isNotEmpty,
            child: person.notes != null && person.notes!.isNotEmpty
                ? Text(person.notes!, style: const TextStyle(fontSize: 13))
                : null,
          ),

          // Gift Ideas
          _section(
            'Gift Ideas',
            color: AppColors.yellowLight,
            hasData:
                person.giftIdeas != null && person.giftIdeas!.isNotEmpty,
            child: person.giftIdeas != null && person.giftIdeas!.isNotEmpty
                ? Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: person.giftIdeas!
                        .map((i) => TagChip(label: i, color: AppColors.orange))
                        .toList(),
                  )
                : null,
          ),

          // Edit hint
          Center(
            child: TextButton.icon(
              onPressed: () => context.push('/people/${person.id}/edit'),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit profile to add more details'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.purple.withValues(alpha: 0.6),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Get Gift Ideas button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // If user entered an age, create a temp person with calculated birth year
                final personForSuggestion =
                    (!yearIsKnown && _enteredAge != null)
                        ? _personWithAge(person)
                        : person;
                final prefs = ref.read(userPreferencesProvider).value;
                final country = prefs?.country ?? 'AU';
                ref
                    .read(giftSuggestionsProvider.notifier)
                    .fetchSuggestions(personForSuggestion, country: country);
                context.push('/people/${person.id}/gifts/results');
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Get Gift Ideas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Create a copy of person with the calculated birth year from entered age.
  Person _personWithAge(Person person) {
    final birthYear = _calcBirthYear(_enteredAge!, person.dateOfBirth);
    final dob = parseDob(person.dateOfBirth);
    final newDob = buildDob(birthYear, dob.month, dob.day);
    return person.copyWith(dateOfBirth: newDob);
  }

  Widget _buildSaveYearPrompt(String dateOfBirth) {
    final birthYear = _calcBirthYear(_enteredAge!, dateOfBirth);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.save_outlined,
              color: AppColors.teal, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Save birth year ($birthYear) to profile?',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => _saveBirthYear(birthYear),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
            ),
            child: const Text('Save'),
          ),
          SizedBox(
            width: 32,
            child: IconButton(
              icon: Icon(Icons.close,
                  size: 16,
                  color: AppColors.fg(context).withValues(alpha: 0.4)),
              onPressed: () => setState(() => _yearSaved = true),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title,
      {required Color color, required bool hasData, Widget? child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.fg(context),
              ),
            ),
            const SizedBox(height: 6),
            if (hasData && child != null)
              child
            else
              Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16,
                      color: AppColors.fg(context).withValues(alpha: 0.3)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Not provided — add this for better suggestions',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.fg(context).withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
