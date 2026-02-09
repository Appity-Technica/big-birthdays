import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

  List<Person> _filtered(List<Person> people) {
    var result = people.toList();
    if (_filterRelationship != null) {
      result =
          result.where((p) => p.relationship == _filterRelationship).toList();
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

  @override
  Widget build(BuildContext context) {
    final peopleAsync = ref.watch(peopleStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('People', style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_contacts),
            tooltip: 'Import',
            onPressed: () => context.push('/people/import'),
          ),
        ],
      ),
      body: peopleAsync.when(
        loading: () => const LoadingSpinner(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (people) {
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
                        child: Text(
                          'No people found.',
                          style: TextStyle(
                            color:
                                AppColors.fg(context).withValues(alpha: 0.4),
                          ),
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
