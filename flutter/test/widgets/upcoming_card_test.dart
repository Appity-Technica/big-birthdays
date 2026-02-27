import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/screens/dashboard/widgets/upcoming_card.dart';
import 'package:big_birthdays/models/person.dart';
import 'package:big_birthdays/models/enums.dart';

void main() {
  Widget buildTestWidget(UpcomingCard card) {
    return MaterialApp(home: Scaffold(body: SingleChildScrollView(child: card)));
  }

  Person makePerson({
    String name = 'Alice Smith',
    String? dateOfBirth,
    Relationship relationship = Relationship.friend,
  }) {
    final now = DateTime.now();
    // Default to tomorrow's date with known year
    final tomorrow = now.add(const Duration(days: 1));
    return Person(
      id: 'test-1',
      name: name,
      dateOfBirth: dateOfBirth ??
          '${now.year - 25}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}',
      relationship: relationship,
      createdAt: '2024-01-01',
      updatedAt: '2024-01-01',
    );
  }

  group('UpcomingCard', () {
    testWidgets('displays person name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        UpcomingCard(person: makePerson(name: 'Jane Doe'), index: 0),
      ));

      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('displays relationship chip', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        UpcomingCard(
          person: makePerson(relationship: Relationship.colleague),
          index: 0,
        ),
      ));

      expect(find.text('Colleague'), findsOneWidget);
    });

    testWidgets('displays "Tomorrow" when birthday is 1 day away', (tester) async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final dob = '${now.year - 20}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        UpcomingCard(person: makePerson(dateOfBirth: dob), index: 0),
      ));

      expect(find.text('Tomorrow'), findsOneWidget);
    });

    testWidgets('displays "In N days" when birthday is more than 1 day away', (tester) async {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 10));
      final dob = '${now.year - 20}-${future.month.toString().padLeft(2, '0')}-${future.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        UpcomingCard(person: makePerson(dateOfBirth: dob), index: 0),
      ));

      expect(find.text('In 10 days'), findsOneWidget);
    });

    testWidgets('displays "Turning X" chip when year is known', (tester) async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final dob = '${now.year - 30}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        UpcomingCard(person: makePerson(dateOfBirth: dob), index: 0),
      ));

      expect(find.text('Turning 30'), findsOneWidget);
    });

    testWidgets('does not display "Turning" chip when year is unknown', (tester) async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final dob = '0000-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        UpcomingCard(person: makePerson(dateOfBirth: dob), index: 0),
      ));

      expect(find.textContaining('Turning'), findsNothing);
    });

    testWidgets('has semantics label with age for tomorrow', (tester) async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final dob = '${now.year - 35}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        UpcomingCard(
          person: makePerson(name: 'Bob', dateOfBirth: dob),
          index: 0,
        ),
      ));

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == "Bob's birthday tomorrow, turning 35",
        ),
      );
      expect(semantics.properties.button, isTrue);
    });

    testWidgets('has semantics label for N days away without age', (tester) async {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 5));
      final dob = '0000-${future.month.toString().padLeft(2, '0')}-${future.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        UpcomingCard(
          person: makePerson(name: 'Eve', dateOfBirth: dob),
          index: 0,
        ),
      ));

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == "Eve's birthday in 5 days",
        ),
      );
      expect(semantics.properties.button, isTrue);
    });

    testWidgets('responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildTestWidget(
        UpcomingCard(
          person: makePerson(),
          index: 0,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });
  });
}
