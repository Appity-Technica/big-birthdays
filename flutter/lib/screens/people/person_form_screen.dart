import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/enums.dart';
import '../../models/person.dart';
import '../../providers/auth_provider.dart';
import '../../providers/people_provider.dart';
import 'widgets/star_rating.dart';

class PersonFormScreen extends ConsumerStatefulWidget {
  final String? personId;
  const PersonFormScreen({super.key, this.personId});

  @override
  ConsumerState<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends ConsumerState<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _connectedThroughController = TextEditingController();
  final _knownFromCustomController = TextEditingController();
  final _notesController = TextEditingController();
  final _interestsController = TextEditingController();
  final _giftIdeasController = TextEditingController();

  int? _birthDay;
  int? _birthMonth;
  int? _birthYear;
  Relationship _relationship = Relationship.friend;
  KnownFrom? _knownFrom;

  // Parties
  final List<_PartyForm> _parties = [];

  // Past gifts
  final List<_GiftForm> _gifts = [];

  // Notification override
  bool _useCustomNotifications = false;
  Set<NotificationTiming> _notificationTimings = {};

  bool _saving = false;
  bool get _isEdit => widget.personId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPerson());
    }
  }

  void _loadPerson() {
    final person = ref.read(personByIdProvider(widget.personId!));
    if (person == null) return;

    final dob = parseDob(person.dateOfBirth);
    _nameController.text = person.name;
    _birthDay = dob.day;
    _birthMonth = dob.month;
    _birthYear = dob.year;
    _relationship = person.relationship;
    _connectedThroughController.text = person.connectedThrough ?? '';
    _knownFrom = person.knownFrom;
    _knownFromCustomController.text = person.knownFromCustom ?? '';
    _notesController.text = person.notes ?? '';
    _interestsController.text = person.interests?.join(', ') ?? '';
    _giftIdeasController.text = person.giftIdeas?.join(', ') ?? '';

    if (person.parties != null) {
      for (final p in person.parties!) {
        _parties.add(_PartyForm(
          yearController: TextEditingController(text: '${p.year}'),
          dateController: TextEditingController(text: p.date ?? ''),
          invitedController:
              TextEditingController(text: p.invitedNames?.join(', ') ?? ''),
          notesController: TextEditingController(text: p.notes ?? ''),
        ));
      }
    }

    if (person.pastGifts != null) {
      for (final g in person.pastGifts!) {
        _gifts.add(_GiftForm(
          yearController: TextEditingController(text: '${g.year}'),
          descController: TextEditingController(text: g.description),
          urlController: TextEditingController(text: g.url ?? ''),
          rating: g.rating ?? 0,
        ));
      }
    }

    if (person.notificationTimings != null &&
        person.notificationTimings!.isNotEmpty) {
      _useCustomNotifications = true;
      _notificationTimings = person.notificationTimings!.toSet();
    }

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _connectedThroughController.dispose();
    _knownFromCustomController.dispose();
    _notesController.dispose();
    _interestsController.dispose();
    _giftIdeasController.dispose();
    for (final p in _parties) {
      p.yearController.dispose();
      p.dateController.dispose();
      p.invitedController.dispose();
      p.notesController.dispose();
    }
    for (final g in _gifts) {
      g.yearController.dispose();
      g.descController.dispose();
      g.urlController.dispose();
    }
    super.dispose();
  }

  List<String> _splitComma(String text) {
    return text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDay == null || _birthMonth == null) return;

    setState(() => _saving = true);

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final dob = buildDob(_birthYear, _birthMonth!, _birthDay!);
    final interests = _splitComma(_interestsController.text);
    final giftIdeas = _splitComma(_giftIdeasController.text);

    final parties = _parties
        .where((p) => p.yearController.text.isNotEmpty)
        .map((p) => Party(
              year: int.tryParse(p.yearController.text) ?? 0,
              date: p.dateController.text.isNotEmpty
                  ? p.dateController.text
                  : null,
              invitedNames: p.invitedController.text.isNotEmpty
                  ? _splitComma(p.invitedController.text)
                  : null,
              notes: p.notesController.text.isNotEmpty
                  ? p.notesController.text
                  : null,
            ))
        .toList();

    final pastGifts = _gifts
        .where((g) => g.descController.text.isNotEmpty)
        .map((g) => PastGift(
              year: int.tryParse(g.yearController.text) ?? 0,
              description: g.descController.text,
              url: g.urlController.text.isNotEmpty ? g.urlController.text : null,
              rating: g.rating > 0 ? g.rating : null,
            ))
        .toList();

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'dateOfBirth': dob,
      'relationship': _relationship.firestoreValue,
    };

    final ct = _connectedThroughController.text.trim();
    if (ct.isNotEmpty) data['connectedThrough'] = ct;
    if (_knownFrom != null) data['knownFrom'] = _knownFrom!.firestoreValue;
    final kfc = _knownFromCustomController.text.trim();
    if (kfc.isNotEmpty) data['knownFromCustom'] = kfc;
    final notes = _notesController.text.trim();
    if (notes.isNotEmpty) data['notes'] = notes;
    if (interests.isNotEmpty) data['interests'] = interests;
    if (giftIdeas.isNotEmpty) data['giftIdeas'] = giftIdeas;
    if (pastGifts.isNotEmpty) {
      data['pastGifts'] = pastGifts.map((g) => g.toMap()).toList();
    }
    if (parties.isNotEmpty) {
      data['parties'] = parties.map((p) => p.toMap()).toList();
    }
    if (_useCustomNotifications && _notificationTimings.isNotEmpty) {
      data['notificationTimings'] =
          _notificationTimings.map((t) => t.firestoreValue).toList();
    }

    try {
      final repo = ref.read(peopleRepositoryProvider);
      if (_isEdit) {
        await repo.updatePerson(user.uid, widget.personId!, data);
      } else {
        await repo.addPerson(user.uid, data);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Person' : 'Add Birthday'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Birthday
            Text('Birthday *',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _birthDay,
                    decoration: const InputDecoration(labelText: 'Day'),
                    items: List.generate(
                        31,
                        (i) => DropdownMenuItem(
                            value: i + 1, child: Text('${i + 1}'))),
                    onChanged: (v) => setState(() => _birthDay = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _birthMonth,
                    decoration: const InputDecoration(labelText: 'Month'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('January')),
                      DropdownMenuItem(value: 2, child: Text('February')),
                      DropdownMenuItem(value: 3, child: Text('March')),
                      DropdownMenuItem(value: 4, child: Text('April')),
                      DropdownMenuItem(value: 5, child: Text('May')),
                      DropdownMenuItem(value: 6, child: Text('June')),
                      DropdownMenuItem(value: 7, child: Text('July')),
                      DropdownMenuItem(value: 8, child: Text('August')),
                      DropdownMenuItem(value: 9, child: Text('September')),
                      DropdownMenuItem(value: 10, child: Text('October')),
                      DropdownMenuItem(value: 11, child: Text('November')),
                      DropdownMenuItem(value: 12, child: Text('December')),
                    ],
                    onChanged: (v) => setState(() => _birthMonth = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    initialValue: _birthYear?.toString(),
                    decoration:
                        const InputDecoration(labelText: 'Year', hintText: 'Optional'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        _birthYear = v.isNotEmpty ? int.tryParse(v) : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Relationship
            Text('Relationship',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Relationship.values.map((r) {
                final selected = _relationship == r;
                return ChoiceChip(
                  label: Text(r.displayLabel),
                  selected: selected,
                  onSelected: (_) => setState(() => _relationship = r),
                  selectedColor: AppColors.purple.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.purple : AppColors.fg(context),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Connection section
            _sectionContainer(
              color: AppColors.lav(context),
              title: 'How do you know them?',
              children: [
                TextFormField(
                  controller: _connectedThroughController,
                  decoration:
                      const InputDecoration(labelText: 'Connected through'),
                ),
                const SizedBox(height: 12),
                Text('Known from',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.fg(context).withValues(alpha: 0.6))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: KnownFrom.values.map((kf) {
                    final selected = _knownFrom == kf;
                    return ChoiceChip(
                      label: Text(kf.displayLabel),
                      selected: selected,
                      onSelected: (_) => setState(
                          () => _knownFrom = selected ? null : kf),
                      selectedColor: AppColors.teal.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? AppColors.teal : AppColors.fg(context),
                      ),
                    );
                  }).toList(),
                ),
                if (_knownFrom == KnownFrom.other) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _knownFromCustomController,
                    decoration: const InputDecoration(labelText: 'Specify'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Parties
            _sectionContainer(
              color: AppColors.mn(context),
              title: 'Parties',
              children: [
                ..._parties.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: p.yearController,
                                decoration:
                                    const InputDecoration(labelText: 'Year'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: p.dateController,
                                decoration:
                                    const InputDecoration(labelText: 'Date'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppColors.coral),
                              onPressed: () =>
                                  setState(() => _parties.removeAt(i)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: p.invitedController,
                          decoration: const InputDecoration(
                              labelText: 'Who was invited (comma-separated)'),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: p.notesController,
                          decoration:
                              const InputDecoration(labelText: 'Party notes'),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => _parties.add(_PartyForm(
                        yearController: TextEditingController(
                            text: '${DateTime.now().year}'),
                        dateController: TextEditingController(),
                        invitedController: TextEditingController(),
                        notesController: TextEditingController(),
                      ))),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Party'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Interests
            TextFormField(
              controller: _interestsController,
              decoration: const InputDecoration(
                  labelText: 'Interests (comma-separated)'),
            ),
            const SizedBox(height: 16),

            // Gift Ideas
            TextFormField(
              controller: _giftIdeasController,
              decoration: const InputDecoration(
                  labelText: 'Gift Ideas (comma-separated)'),
            ),
            const SizedBox(height: 16),

            // Past Gifts
            _sectionContainer(
              color: AppColors.pinkLight,
              title: 'Past Gifts',
              children: [
                ..._gifts.asMap().entries.map((entry) {
                  final i = entry.key;
                  final g = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: g.yearController,
                                decoration:
                                    const InputDecoration(labelText: 'Year'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: g.descController,
                                decoration: const InputDecoration(
                                    labelText: 'Description'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppColors.coral),
                              onPressed: () =>
                                  setState(() => _gifts.removeAt(i)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: g.urlController,
                                decoration: const InputDecoration(
                                    labelText: 'Link (optional)'),
                                keyboardType: TextInputType.url,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rating',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.fg(context)
                                            .withValues(alpha: 0.5))),
                                StarRating(
                                  rating: g.rating,
                                  size: 28,
                                  onChanged: (v) =>
                                      setState(() => g.rating = v),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => _gifts.add(_GiftForm(
                        yearController: TextEditingController(
                            text: '${DateTime.now().year}'),
                        descController: TextEditingController(),
                        urlController: TextEditingController(),
                      ))),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Gift'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notification Override
            _sectionContainer(
              color: AppColors.yellowLight,
              title: 'Notification Override',
              children: [
                SwitchListTile(
                  value: _useCustomNotifications,
                  onChanged: (v) =>
                      setState(() => _useCustomNotifications = v),
                  title: const Text('Use custom timings',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                    'Override default notification timings for this person',
                    style: TextStyle(fontSize: 12),
                  ),
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.purple,
                ),
                if (_useCustomNotifications)
                  ...NotificationTiming.values.map((t) => CheckboxListTile(
                        value: _notificationTimings.contains(t),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _notificationTimings.add(t);
                            } else {
                              _notificationTimings.remove(t);
                            }
                          });
                        },
                        title: Text(t.displayLabel,
                            style: const TextStyle(fontSize: 13)),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.purple,
                        dense: true,
                      )),
              ],
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      )
                    : Text(_isEdit ? 'Save Changes' : 'Add Birthday'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionContainer({
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fg(context))),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _PartyForm {
  final TextEditingController yearController;
  final TextEditingController dateController;
  final TextEditingController invitedController;
  final TextEditingController notesController;

  _PartyForm({
    required this.yearController,
    required this.dateController,
    required this.invitedController,
    required this.notesController,
  });
}

class _GiftForm {
  final TextEditingController yearController;
  final TextEditingController descController;
  final TextEditingController urlController;
  int rating;

  _GiftForm({
    required this.yearController,
    required this.descController,
    required this.urlController,
    this.rating = 0,
  });
}
