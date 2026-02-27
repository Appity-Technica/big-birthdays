import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils.dart';
import '../models/person.dart';
import '../repositories/people_repository.dart';
import 'auth_provider.dart';

/// Provides a singleton [PeopleRepository] instance for Firestore operations.
final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  return PeopleRepository();
});

/// Streams the authenticated user's list of [Person] records from Firestore.
///
/// Returns an empty list when no user is logged in.
final peopleStreamProvider = StreamProvider<List<Person>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(peopleRepositoryProvider).watchPeople(user.uid);
});

/// Provides the list of people whose birthday is today.
final todayBirthdaysProvider = Provider<List<Person>>((ref) {
  final people = ref.watch(peopleStreamProvider).value ?? [];
  return people.where((p) => isBirthdayToday(p.dateOfBirth)).toList();
});

/// Provides the list of people whose birthday is not today, sorted by
/// the number of days until their next birthday (soonest first).
final upcomingBirthdaysProvider = Provider<List<Person>>((ref) {
  final people = ref.watch(peopleStreamProvider).value ?? [];
  final upcoming =
      people.where((p) => !isBirthdayToday(p.dateOfBirth)).toList()
        ..sort((a, b) => daysUntilBirthday(a.dateOfBirth)
            .compareTo(daysUntilBirthday(b.dateOfBirth)));
  return upcoming;
});

/// Provides a map of person ID to [Person] for O(1) lookups.
final peopleMapProvider = Provider<Map<String, Person>>((ref) {
  final people = ref.watch(peopleStreamProvider).value ?? [];
  return {for (final p in people) p.id: p};
});

/// Looks up a single [Person] by their Firestore document [id].
///
/// Returns `null` if no person with that ID exists in the current data.
final personByIdProvider = Provider.family<Person?, String>((ref, id) {
  return ref.watch(peopleMapProvider)[id];
});
