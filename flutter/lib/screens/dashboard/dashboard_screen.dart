import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../providers/people_provider.dart';
import '../../widgets/loading_spinner.dart';
import 'widgets/birthday_today_card.dart';
import 'widgets/upcoming_card.dart';
import 'widgets/person_bottom_sheet.dart';
import 'widgets/stats_row.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(peopleStreamProvider);
    final todayBirthdays = ref.watch(todayBirthdaysProvider);
    final upcoming = ref.watch(upcomingBirthdaysProvider);

    return Scaffold(
      body: peopleAsync.when(
        loading: () => const LoadingSpinner(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (people) {
          if (people.isEmpty) {
            return _emptyState(context);
          }

          final nextDays = upcoming.isNotEmpty
              ? daysUntilBirthday(upcoming.first.dateOfBirth)
              : null;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: Text(
                  'Tiaras & Trains',
                  style: GoogleFonts.baloo2(
                    fontWeight: FontWeight.bold,
                    color: AppColors.purple,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => context.push('/people/new'),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats
                    StatsRow(
                      totalCount: people.length,
                      todayCount: todayBirthdays.length,
                      nextDays: nextDays,
                    ),
                    const SizedBox(height: 24),

                    // Today's birthdays
                    if (todayBirthdays.isNotEmpty) ...[
                      Text(
                        "Today's Birthdays 🎉",
                        style: GoogleFonts.baloo2(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...todayBirthdays.map((p) => BirthdayTodayCard(
                            person: p,
                            onTap: () =>
                                PersonBottomSheet.show(context, p),
                          )),
                      const SizedBox(height: 24),
                    ],

                    // Upcoming
                    if (upcoming.isNotEmpty) ...[
                      Text(
                        'Coming Up',
                        style: GoogleFonts.baloo2(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ]),
                ),
              ),

              if (upcoming.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= 8) return null;
                        final person = upcoming[index];
                        return UpcomingCard(
                          person: person,
                          index: index,
                          onTap: () =>
                              PersonBottomSheet.show(context, person),
                        );
                      },
                      childCount: upcoming.length.clamp(0, 8),
                    ),
                  ),
                ),

              const SliverPadding(
                  padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/people/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎈🎁🎂', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 24),
            Text(
              'No birthdays yet!',
              style: GoogleFonts.baloo2(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first birthday to get started.',
              style: TextStyle(
                color: AppColors.foreground.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/people/new'),
              icon: const Icon(Icons.add),
              label: const Text('Add Birthday'),
            ),
          ],
        ),
      ),
    );
  }
}
