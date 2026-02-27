import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/widgets/initials_avatar.dart';

void main() {
  Widget buildTestWidget(InitialsAvatar avatar) {
    return MaterialApp(
      home: Scaffold(body: avatar),
    );
  }

  group('InitialsAvatar', () {
    testWidgets('displays correct initials for two-word name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const InitialsAvatar(name: 'John Smith'),
      ));

      expect(find.text('JS'), findsOneWidget);
    });

    testWidgets('displays single initial for single name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const InitialsAvatar(name: 'Madonna'),
      ));

      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('default size is 48', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const InitialsAvatar(name: 'Alice Bob'),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final constraints = container.constraints;
      expect(constraints?.maxWidth, 48);
      expect(constraints?.maxHeight, 48);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const InitialsAvatar(name: 'Alice Bob', size: 80),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final constraints = container.constraints;
      expect(constraints?.maxWidth, 80);
      expect(constraints?.maxHeight, 80);
    });

    testWidgets('has correct semantics label', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const InitialsAvatar(name: 'Jane Doe'),
      ));

      expect(
        find.bySemanticsLabel('Avatar for Jane Doe'),
        findsOneWidget,
      );
    });

    testWidgets('uses circular shape', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const InitialsAvatar(name: 'Test User'),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });
  });
}
