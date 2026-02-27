import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/screens/people/widgets/person_list_tile.dart';
import 'package:big_birthdays/models/person.dart';
import 'package:big_birthdays/models/enums.dart';

void main() {
  Widget buildTestWidget(PersonListTile tile) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(children: [tile]),
      ),
    );
  }

  Person makePerson({
    String name = 'Alice Smith',
    String? dateOfBirth,
    Relationship relationship = Relationship.friend,
    String id = 'test-1',
  }) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return Person(
      id: id,
      name: name,
      dateOfBirth: dateOfBirth ??
          '${now.year - 25}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}',
      relationship: relationship,
      createdAt: '2024-01-01',
      updatedAt: '2024-01-01',
    );
  }

  group('PersonListTile', () {
    testWidgets('displays person name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        PersonListTile(person: makePerson(name: 'Jane Doe'), index: 0),
      ));

      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('displays formatted date', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        PersonListTile(
          person: makePerson(dateOfBirth: '1990-03-15'),
          index: 0,
        ),
      ));

      expect(find.text('15 March 1990'), findsOneWidget);
    });

    testWidgets('displays "Today!" chip when birthday is today', (tester) async {
      final now = DateTime.now();
      final dob = '${now.year - 30}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        PersonListTile(person: makePerson(dateOfBirth: dob), index: 0),
      ));

      expect(find.text('Today!'), findsOneWidget);
    });

    testWidgets('displays "Tomorrow" chip when birthday is tomorrow', (tester) async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final dob = '${now.year - 30}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        PersonListTile(person: makePerson(dateOfBirth: dob), index: 0),
      ));

      expect(find.text('Tomorrow'), findsOneWidget);
    });

    testWidgets('displays "N days" chip for future birthdays', (tester) async {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 10));
      final dob = '${now.year - 30}-${future.month.toString().padLeft(2, '0')}-${future.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        PersonListTile(person: makePerson(dateOfBirth: dob), index: 0),
      ));

      expect(find.text('10 days'), findsOneWidget);
    });

    testWidgets('displays age when year is known', (tester) async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final dob = '${now.year - 25}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        PersonListTile(person: makePerson(dateOfBirth: dob), index: 0),
      ));

      expect(find.textContaining('Age'), findsOneWidget);
    });

    testWidgets('does not display age when year is unknown', (tester) async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final dob = '0000-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        PersonListTile(person: makePerson(dateOfBirth: dob), index: 0),
      ));

      expect(find.textContaining('Age'), findsNothing);
    });

    testWidgets('shows edit button when onEdit is provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        PersonListTile(
          person: makePerson(),
          index: 0,
          onEdit: () {},
        ),
      ));

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('does not show edit button when onEdit is null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        PersonListTile(person: makePerson(), index: 0),
      ));

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });

    testWidgets('onTap callback fires', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildTestWidget(
        PersonListTile(
          person: makePerson(),
          index: 0,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });

    testWidgets('onEdit callback fires', (tester) async {
      bool edited = false;
      await tester.pumpWidget(buildTestWidget(
        PersonListTile(
          person: makePerson(),
          index: 0,
          onEdit: () => edited = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.edit_outlined));
      expect(edited, isTrue);
    });
  });
}
