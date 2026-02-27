import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/screens/people/widgets/star_rating.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('StarRatingDisplay', () {
    testWidgets('renders 5 stars', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StarRatingDisplay(rating: 3),
      ));

      expect(find.byType(Icon), findsNWidgets(5));
    });

    testWidgets('shows correct number of filled stars for rating 3', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StarRatingDisplay(rating: 3),
      ));

      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      final filledCount = icons.where((i) => i.icon == Icons.star_rounded).length;
      final outlineCount = icons.where((i) => i.icon == Icons.star_outline_rounded).length;
      expect(filledCount, 3);
      expect(outlineCount, 2);
    });

    testWidgets('shows 0 filled stars for rating 0', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StarRatingDisplay(rating: 0),
      ));

      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      final filledCount = icons.where((i) => i.icon == Icons.star_rounded).length;
      expect(filledCount, 0);
    });

    testWidgets('shows 5 filled stars for rating 5', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StarRatingDisplay(rating: 5),
      ));

      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      final filledCount = icons.where((i) => i.icon == Icons.star_rounded).length;
      expect(filledCount, 5);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StarRatingDisplay(rating: 1, size: 32),
      ));

      final icon = tester.widget<Icon>(find.byType(Icon).first);
      expect(icon.size, 32);
    });
  });

  group('StarRating', () {
    testWidgets('renders 5 stars', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StarRating(rating: 2),
      ));

      expect(find.byType(Icon), findsNWidgets(5));
    });

    testWidgets('tapping a star calls onChanged with that star number', (tester) async {
      int? changedTo;
      await tester.pumpWidget(buildTestWidget(
        StarRating(
          rating: 0,
          onChanged: (v) => changedTo = v,
        ),
      ));

      // Tap the 3rd star (index 2)
      await tester.tap(find.byType(GestureDetector).at(2));
      expect(changedTo, 3);
    });

    testWidgets('tapping current rating toggles to 0', (tester) async {
      int? changedTo;
      await tester.pumpWidget(buildTestWidget(
        StarRating(
          rating: 3,
          onChanged: (v) => changedTo = v,
        ),
      ));

      // Tap the 3rd star (index 2), which is the current rating
      await tester.tap(find.byType(GestureDetector).at(2));
      expect(changedTo, 0);
    });

    testWidgets('tapping different star changes to that rating', (tester) async {
      int? changedTo;
      await tester.pumpWidget(buildTestWidget(
        StarRating(
          rating: 2,
          onChanged: (v) => changedTo = v,
        ),
      ));

      // Tap the 5th star (index 4)
      await tester.tap(find.byType(GestureDetector).at(4));
      expect(changedTo, 5);
    });

    testWidgets('no callback when onChanged is null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StarRating(rating: 3),
      ));

      // Tap should not throw
      await tester.tap(find.byType(GestureDetector).first);
    });
  });
}
