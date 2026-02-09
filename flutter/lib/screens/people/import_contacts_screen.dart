import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/people_provider.dart';
import '../../repositories/contacts_repository.dart';
import '../../widgets/initials_avatar.dart';
import '../../widgets/loading_spinner.dart';

class ImportContactsScreen extends ConsumerStatefulWidget {
  const ImportContactsScreen({super.key});

  @override
  ConsumerState<ImportContactsScreen> createState() =>
      _ImportContactsScreenState();
}

class _ImportContactsScreenState extends ConsumerState<ImportContactsScreen> {
  int _step = 0; // 0=start, 1=select, 2=done
  List<DeviceContact> _contacts = [];
  Set<int> _selected = {};
  bool _loading = false;
  int _importedCount = 0;

  Future<void> _loadContacts() async {
    setState(() => _loading = true);
    try {
      final repo = ContactsRepository();
      final contacts = await repo.getContactsWithBirthdays();

      // Check for duplicates
      final people = ref.read(peopleStreamProvider).value ?? [];
      final existingNames =
          people.map((p) => p.name.toLowerCase()).toSet();

      _contacts = contacts;
      _selected = {};
      for (var i = 0; i < contacts.length; i++) {
        if (!existingNames.contains(contacts[i].name.toLowerCase())) {
          _selected.add(i);
        }
      }
      setState(() {
        _step = 1;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _import() async {
    setState(() => _loading = true);
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final repo = ref.read(peopleRepositoryProvider);
    var count = 0;
    for (final idx in _selected) {
      final contact = _contacts[idx];
      await repo.addPerson(user.uid, {
        'name': contact.name,
        'dateOfBirth': contact.dateOfBirth,
        'relationship': Relationship.friend.firestoreValue,
      });
      count++;
    }

    setState(() {
      _importedCount = count;
      _step = 2;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Contacts')),
      body: _loading
          ? const LoadingSpinner()
          : _step == 0
              ? _buildStart()
              : _step == 1
                  ? _buildSelect()
                  : _buildDone(),
    );
  }

  Widget _buildStart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.contacts_outlined,
                size: 64, color: AppColors.purple),
            const SizedBox(height: 16),
            Text(
              'Import from Contacts',
              style: GoogleFonts.baloo2(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find contacts with birthdays and add them to your list.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.fg(context).withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadContacts,
              icon: const Icon(Icons.people),
              label: const Text('Import from Device Contacts'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelect() {
    final people = ref.watch(peopleStreamProvider).value ?? [];
    final existingNames = people.map((p) => p.name.toLowerCase()).toSet();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${_contacts.length} contacts found · ${_selected.length} selected',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.fg(context).withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() =>
                    _selected = Set.from(List.generate(_contacts.length, (i) => i))),
                child: const Text('All'),
              ),
              TextButton(
                onPressed: () => setState(() => _selected = {}),
                child: const Text('None'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              final isDuplicate =
                  existingNames.contains(contact.name.toLowerCase());
              return CheckboxListTile(
                value: _selected.contains(index),
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selected.add(index);
                    } else {
                      _selected.remove(index);
                    }
                  });
                },
                secondary: InitialsAvatar(
                  name: contact.name,
                  size: 40,
                  colorIndex: index,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(contact.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    if (isDuplicate)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Already tracked',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  formatDate(contact.dateOfBirth),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.fg(context).withValues(alpha: 0.5),
                  ),
                ),
                activeColor: AppColors.purple,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected.isEmpty ? null : _import,
              child: Text('Import ${_selected.length} Contacts'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDone() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '$_importedCount birthdays imported!',
              style: GoogleFonts.baloo2(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/people'),
              child: const Text('View People'),
            ),
          ],
        ),
      ),
    );
  }
}
