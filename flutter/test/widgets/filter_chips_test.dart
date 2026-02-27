import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/screens/people/widgets/filter_chips.dart';
import 'package:big_birthdays/models/enums.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('RelationshipFilterChips', () {
    testWidgets('renders All chip plus one per relationship value', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        RelationshipFilterChips(
          selected: null,
          onChanged: (_) {},
        ),
      ));

      // All + Family + Friend + Colleague + Other = 5 chips
      expect(find.byType(FilterChip), findsNWidgets(5));
    });

    testWidgets('displays All chip label', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        RelationshipFilterChips(
          selected: null,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('displays all relationship labels', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        RelationshipFilterChips(
          selected: null,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Family'), findsOneWidget);
      expect(find.text('Friend'), findsOneWidget);
      expect(find.text('Colleague'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('All chip is selected when selected is null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        RelationshipFilterChips(
          selected: null,
          onChanged: (_) {},
        ),
      ));

      final allChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'All'),
      );
      expect(allChip.selected, isTrue);
    });

    testWidgets('Family chip is selected when family is selected', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        RelationshipFilterChips(
          selected: Relationship.family,
          onChanged: (_) {},
        ),
      ));

      final familyChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Family'),
      );
      expect(familyChip.selected, isTrue);

      final allChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'All'),
      );
      expect(allChip.selected, isFalse);
    });

    testWidgets('tapping All calls onChanged with null', (tester) async {
      Relationship? result = Relationship.family;
      await tester.pumpWidget(buildTestWidget(
        RelationshipFilterChips(
          selected: Relationship.family,
          onChanged: (r) => result = r,
        ),
      ));

      await tester.tap(find.widgetWithText(FilterChip, 'All'));
      expect(result, isNull);
    });

    testWidgets('tapping Friend calls onChanged with friend', (tester) async {
      Relationship? result;
      await tester.pumpWidget(buildTestWidget(
        RelationshipFilterChips(
          selected: null,
          onChanged: (r) => result = r,
        ),
      ));

      await tester.tap(find.widgetWithText(FilterChip, 'Friend'));
      expect(result, Relationship.friend);
    });
  });

  group('SortToggle', () {
    testWidgets('displays Upcoming and A-Z buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        SortToggle(
          mode: SortMode.upcoming,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('A-Z'), findsOneWidget);
    });

    testWidgets('tapping A-Z calls onChanged with alphabetical', (tester) async {
      SortMode? result;
      await tester.pumpWidget(buildTestWidget(
        SortToggle(
          mode: SortMode.upcoming,
          onChanged: (m) => result = m,
        ),
      ));

      await tester.tap(find.text('A-Z'));
      expect(result, SortMode.alphabetical);
    });

    testWidgets('tapping Upcoming calls onChanged with upcoming', (tester) async {
      SortMode? result;
      await tester.pumpWidget(buildTestWidget(
        SortToggle(
          mode: SortMode.alphabetical,
          onChanged: (m) => result = m,
        ),
      ));

      await tester.tap(find.text('Upcoming'));
      expect(result, SortMode.upcoming);
    });
  });
}
