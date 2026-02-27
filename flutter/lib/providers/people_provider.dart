import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils.dart';
import '../models/person.dart';
import '../repositories/people_repository.dart';
import 'auth_provider.dart';

final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  return PeopleRepository();
});

final peopleStreamProvider = StreamProvider<List<Person>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(peopleRepositoryProvider).watchPeople(user.uid);
});

final todayBirthdaysProvider = Provider<List<Person>>((ref) {
  final people = ref.watch(peopleStreamProvider).value ?? [];
  return people.where((p) => isBirthdayToday(p.dateOfBirth)).toList();
});

final upcomingBirthdaysProvider = Provider<List<Person>>((ref) {
  final people = ref.watch(peopleStreamProvider).value ?? [];
  final upcoming =
      people.where((p) => !isBirthdayToday(p.dateOfBirth)).toList()
        ..sort((a, b) => daysUntilBirthday(a.dateOfBirth)
            .compareTo(daysUntilBirthday(b.dateOfBirth)));
  return upcoming;
});

final peopleMapProvider = Provider<Map<String, Person>>((ref) {
  final people = ref.watch(peopleStreamProvider).value ?? [];
  return {for (final p in people) p.id: p};
});

final personByIdProvider = Provider.family<Person?, String>((ref, id) {
  return ref.watch(peopleMapProvider)[id];
});
