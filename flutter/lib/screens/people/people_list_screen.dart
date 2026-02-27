import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/analytics.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/enums.dart';
import '../../models/person.dart';
import '../../providers/people_provider.dart';
import '../../widgets/loading_spinner.dart';
import 'widgets/filter_chips.dart';
import 'widgets/person_list_tile.dart';

class PeopleListScreen extends ConsumerStatefulWidget {
  const PeopleListScreen({super.key});

  @override
  ConsumerState<PeopleListScreen> createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends ConsumerState<PeopleListScreen> {
  Relationship? _filterRelationship;
  SortMode _sortMode = SortMode.upcoming;
  String _searchQuery = '';
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Person> _filtered(List<Person> people) {
    var result = people.toList();
    if (_filterRelationship != null) {
      result =
          result.where((p) => p.relationship == _filterRelationship).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }
    if (_sortMode == SortMode.upcoming) {
      result.sort((a, b) => daysUntilBirthday(a.dateOfBirth)
          .compareTo(daysUntilBirthday(b.dateOfBirth)));
    } else {
      result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return result;
  }

  String _escapeCsvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _buildCsv(List<Person> people) {
    final buffer = StringBuffer();
    buffer.writeln(
        'Name,Date of Birth,Relationship,Connected Through,Known From,Notes,Interests,Gift Ideas');
    for (final person in people) {
      final knownFrom = person.knownFrom?.displayLabel ?? '';
      final interests = (person.interests ?? []).join('; ');
      final giftIdeas = (person.giftIdeas ?? []).join('; ');
      buffer.writeln([
        _escapeCsvField(person.name),
        _escapeCsvField(person.dateOfBirth),
        _escapeCsvField(person.relationship.displayLabel),
        _escapeCsvField(person.connectedThrough ?? ''),
        _escapeCsvField(knownFrom),
        _escapeCsvField(person.notes ?? ''),
        _escapeCsvField(interests),
        _escapeCsvField(giftIdeas),
      ].join(','));
    }
    return buffer.toString();
  }

  void _shareFilteredPeople(List<Person> filtered) {
    Analytics.logExportPeople(count: filtered.length);
    final csv = _buildCsv(filtered);
    Share.share(csv, subject: 'Big Birthdays – People Export');
  }

  void _closeSearch() {
    setState(() {
      _showSearch = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final peopleAsync = ref.watch(peopleStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search people...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: AppColors.fg(context).withValues(alpha: 0.4),
                  ),
                ),
                style: TextStyle(color: AppColors.fg(context)),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : Text('People',
                style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
        actions: [
          if (_showSearch)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close search',
              onPressed: _closeSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () => setState(() => _showSearch = true),
            ),
          IconButton(
            icon: const Icon(Icons.import_contacts),
            tooltip: 'Import',
            onPressed: () => context.push('/people/import'),
          ),
          peopleAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (people) {
              final filtered = _filtered(people);
              return IconButton(
                icon: const Icon(Icons.ios_share),
                tooltip: 'Export',
                onPressed:
                    filtered.isEmpty ? null : () => _shareFilteredPeople(filtered),
              );
            },
          ),
        ],
      ),
      body: peopleAsync.when(
        loading: () => const LoadingSpinner(),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off,
                    size: 48,
                    color: AppColors.coral.withValues(alpha: 0.7)),
                const SizedBox(height: 16),
                Text(
                  'Unable to load people',
                  style: GoogleFonts.baloo2(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.fg(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.fg(context).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(peopleStreamProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (people) {
          if (people.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline,
                        size: 64,
                        color: AppColors.purple.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'No people yet',
                      style: GoogleFonts.baloo2(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first person to start tracking birthdays.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.fg(context).withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/people/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Person'),
                    ),
                  ],
                ),
              ),
            );
          }

          final filtered = _filtered(people);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: RelationshipFilterChips(
                        selected: _filterRelationship,
                        onChanged: (v) =>
                            setState(() => _filterRelationship = v),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} ${filtered.length == 1 ? 'person' : 'people'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.fg(context).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    SortToggle(
                      mode: _sortMode,
                      onChanged: (m) => setState(() => _sortMode = m),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off,
                                size: 40,
                                color: AppColors.fg(context).withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text(
                              'No people found',
                              style: TextStyle(
                                color: AppColors.fg(context)
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty ||
                                _filterRelationship != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Try adjusting your search or filters.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.fg(context)
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (context, _) => Divider(
                          height: 1,
                          color: AppColors.lav(context).withValues(alpha: 0.5),
                        ),
                        itemBuilder: (context, index) {
                          final person = filtered[index];
                          return PersonListTile(
                            person: person,
                            index: index,
                            onTap: () =>
                                context.push('/people/${person.id}'),
                            onEdit: () =>
                                context.push('/people/${person.id}/edit'),
                          );
                        },
                      ),
              ),
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
}
