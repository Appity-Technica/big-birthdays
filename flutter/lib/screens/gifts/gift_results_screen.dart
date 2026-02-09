import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../providers/people_provider.dart';
import '../../providers/gift_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/loading_spinner.dart';
import '../../widgets/tag_chip.dart';

class GiftResultsScreen extends ConsumerWidget {
  final String personId;
  const GiftResultsScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(personByIdProvider(personId));
    final suggestionsAsync = ref.watch(giftSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Ideas',
            style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
      ),
      body: suggestionsAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LoadingSpinner(),
              const SizedBox(height: 20),
              Text(
                'Finding the perfect gifts...',
                style: GoogleFonts.baloo2(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a moment',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.fg(context).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48,
                    color: AppColors.coral.withValues(alpha: 0.7)),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: GoogleFonts.baloo2(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.fg(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.fg(context).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (person != null) {
                      final prefs = ref.read(userPreferencesProvider).value;
                      final country = prefs?.country ?? 'AU';
                      ref
                          .read(giftSuggestionsProvider.notifier)
                          .fetchSuggestions(person, country: country);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (suggestions) {
          if (suggestions.isEmpty) {
            return const Center(child: LoadingSpinner());
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Here are some ideas${person != null ? ' for ${person.name}' : ''}',
                style: GoogleFonts.baloo2(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.purple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...suggestions.asMap().entries.map((entry) {
                final index = entry.key;
                final gift = entry.value;
                final colors = [
                  AppColors.mn(context),
                  AppColors.lav(context),
                  AppColors.yellowLight,
                ];
                final accentColors = [
                  AppColors.teal,
                  AppColors.purple,
                  AppColors.orange,
                ];
                final bgColor = colors[index % colors.length];
                final accent = accentColors[index % accentColors.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: bgColor.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.card_giftcard,
                                color: accent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                gift.name,
                                style: GoogleFonts.baloo2(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.fg(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gift.description,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                AppColors.fg(context).withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (gift.estimatedPrice.isNotEmpty)
                              TagChip(
                                label: gift.estimatedPrice,
                                color: AppColors.orange,
                              ),
                            const Spacer(),
                            if (gift.purchaseUrl.isNotEmpty)
                              OutlinedButton.icon(
                                onPressed: () => launchUrl(
                                  Uri.parse(gift.purchaseUrl),
                                  mode: LaunchMode.externalApplication,
                                ),
                                icon: const Icon(Icons.open_in_new,
                                    size: 14),
                                label: const Text('Buy'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: accent,
                                  side: BorderSide(
                                      color: accent.withValues(alpha: 0.4)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (person != null) {
                      final prefs = ref.read(userPreferencesProvider).value;
                      final country = prefs?.country ?? 'AU';
                      ref
                          .read(giftSuggestionsProvider.notifier)
                          .fetchSuggestions(person, country: country);
                    }
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Get More Ideas'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.purple,
                    side: BorderSide(
                        color: AppColors.purple.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
