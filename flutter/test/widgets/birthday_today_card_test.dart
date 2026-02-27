import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/screens/dashboard/widgets/birthday_today_card.dart';
import 'package:big_birthdays/models/person.dart';
import 'package:big_birthdays/models/enums.dart';

void main() {
  Widget buildTestWidget(BirthdayTodayCard card) {
    return MaterialApp(home: Scaffold(body: SingleChildScrollView(child: card)));
  }

  Person makePerson({
    String name = 'Alice Smith',
    String? dateOfBirth,
    Relationship relationship = Relationship.friend,
  }) {
    final now = DateTime.now();
    return Person(
      id: 'test-1',
      name: name,
      dateOfBirth: dateOfBirth ??
          '${now.year - 30}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      relationship: relationship,
      createdAt: '2024-01-01',
      updatedAt: '2024-01-01',
    );
  }

  group('BirthdayTodayCard', () {
    testWidgets('displays person name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        BirthdayTodayCard(person: makePerson(name: 'Jane Doe')),
      ));

      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('displays relationship chip', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        BirthdayTodayCard(
          person: makePerson(relationship: Relationship.family),
        ),
      ));

      expect(find.text('Family'), findsOneWidget);
    });

    testWidgets('displays "Turning X" chip when year is known', (tester) async {
      final now = DateTime.now();
      final dob = '${now.year - 25}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        BirthdayTodayCard(person: makePerson(dateOfBirth: dob)),
      ));

      expect(find.text('Turning 25'), findsOneWidget);
    });

    testWidgets('does not display "Turning" chip when year is unknown', (tester) async {
      final now = DateTime.now();
      final dob = '0000-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        BirthdayTodayCard(person: makePerson(dateOfBirth: dob)),
      ));

      expect(find.textContaining('Turning'), findsNothing);
    });

    testWidgets('has semantics label with age when known', (tester) async {
      final now = DateTime.now();
      final dob = '${now.year - 40}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        BirthdayTodayCard(person: makePerson(name: 'Bob', dateOfBirth: dob)),
      ));

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == "Bob's birthday today, turning 40",
        ),
      );
      expect(semantics.properties.button, isTrue);
    });

    testWidgets('has semantics label without age when year unknown', (tester) async {
      final now = DateTime.now();
      final dob = '0000-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await tester.pumpWidget(buildTestWidget(
        BirthdayTodayCard(person: makePerson(name: 'Bob', dateOfBirth: dob)),
      ));

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == "Bob's birthday today",
        ),
      );
      expect(semantics.properties.button, isTrue);
    });

    testWidgets('responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildTestWidget(
        BirthdayTodayCard(
          person: makePerson(),
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });
  });
}
