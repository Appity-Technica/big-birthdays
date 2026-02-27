import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/screens/dashboard/widgets/stats_row.dart';

void main() {
  Widget buildTestWidget(StatsRow widget) {
    return MaterialApp(home: Scaffold(body: widget));
  }

  group('StatsRow', () {
    testWidgets('displays total count', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatsRow(totalCount: 42, todayCount: 1, nextDays: 5),
      ));

      expect(find.text('42'), findsOneWidget);
      expect(find.text('Tracking'), findsOneWidget);
    });

    testWidgets('displays today count', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatsRow(totalCount: 10, todayCount: 3, nextDays: 2),
      ));

      expect(find.text('3'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('displays next days with "days" suffix', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatsRow(totalCount: 10, todayCount: 0, nextDays: 14),
      ));

      expect(find.text('14 days'), findsOneWidget);
      expect(find.text('Next Up'), findsOneWidget);
    });

    testWidgets('displays dash when nextDays is null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatsRow(totalCount: 0, todayCount: 0),
      ));

      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('has semantics labels', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatsRow(totalCount: 5, todayCount: 2, nextDays: 7),
      ));

      expect(find.bySemanticsLabel('Tracking: 5'), findsOneWidget);
      expect(find.bySemanticsLabel('Today: 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Next Up: 7 days'), findsOneWidget);
    });

    testWidgets('has correct semantics for null nextDays', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatsRow(totalCount: 0, todayCount: 0),
      ));

      expect(find.bySemanticsLabel('Next Up: -'), findsOneWidget);
    });

    testWidgets('displays zero counts correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StatsRow(totalCount: 0, todayCount: 0, nextDays: 0),
      ));

      // "0" appears twice (tracking and today)
      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('0 days'), findsOneWidget);
    });
  });
}
