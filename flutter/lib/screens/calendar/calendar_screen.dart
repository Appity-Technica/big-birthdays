import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/person.dart';
import '../../providers/people_provider.dart';
import '../../widgets/loading_spinner.dart';
import 'widgets/month_summary.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  List<Person> _getEventsForDay(DateTime day, List<Person> people) {
    return people.where((p) {
      final dob = parseDob(p.dateOfBirth);
      return dob.month == day.month && dob.day == day.day;
    }).toList();
  }

  List<Person> _getPeopleForMonth(int month, List<Person> people) {
    return people.where((p) {
      final dob = parseDob(p.dateOfBirth);
      return dob.month == month;
    }).toList()
      ..sort((a, b) {
        final da = parseDob(a.dateOfBirth);
        final db = parseDob(b.dateOfBirth);
        return da.day.compareTo(db.day);
      });
  }

  @override
  Widget build(BuildContext context) {
    final peopleAsync = ref.watch(peopleStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar',
            style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
        actions: [
          if (_focusedDay.month != DateTime.now().month ||
              _focusedDay.year != DateTime.now().year)
            TextButton(
              onPressed: () => setState(() => _focusedDay = DateTime.now()),
              child: const Text('Today'),
            ),
        ],
      ),
      body: peopleAsync.when(
        loading: () => const LoadingSpinner(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (people) {
          final monthPeople =
              _getPeopleForMonth(_focusedDay.month, people);
          final monthLabel = DateFormat('MMMM').format(_focusedDay);

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.baloo2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.purple,
                  ),
                  leftChevronIcon: const Icon(Icons.chevron_left,
                      color: AppColors.purple),
                  rightChevronIcon: const Icon(Icons.chevron_right,
                      color: AppColors.purple),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.purple,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.pink,
                    shape: BoxShape.circle,
                  ),
                  markerSize: 6,
                  markersMaxCount: 3,
                ),
                eventLoader: (day) => _getEventsForDay(day, people),
                onDaySelected: (selectedDay, focusedDay) {
                  final events = _getEventsForDay(selectedDay, people);
                  if (events.length == 1) {
                    context.push('/people/${events.first.id}');
                  } else if (events.isNotEmpty) {
                    _showDayBirthdays(context, selectedDay, events);
                  }
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: MonthSummary(
                    people: monthPeople,
                    monthLabel: monthLabel,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDayBirthdays(
      BuildContext context, DateTime day, List<Person> people) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Birthdays on ${DateFormat('d MMMM').format(day)}',
              style: GoogleFonts.baloo2(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
          ),
          ...people.map((p) => ListTile(
                title: Text(p.name),
                subtitle: Text(p.relationship.displayLabel),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/people/${p.id}');
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
