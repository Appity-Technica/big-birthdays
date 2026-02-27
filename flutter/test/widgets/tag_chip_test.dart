import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:big_birthdays/widgets/tag_chip.dart';

void main() {
  Widget buildTestWidget(TagChip chip) {
    return MaterialApp(home: Scaffold(body: chip));
  }

  group('TagChip', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const TagChip(label: 'Today!', color: Colors.pink),
      ));

      expect(find.text('Today!'), findsOneWidget);
    });

    testWidgets('uses provided color for text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const TagChip(label: 'Test', color: Colors.red),
      ));

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.color, Colors.red);
    });

    testWidgets('default font size is 11', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const TagChip(label: 'Test', color: Colors.blue),
      ));

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.fontSize, 11);
    });

    testWidgets('respects custom font size', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const TagChip(label: 'Test', color: Colors.blue, fontSize: 16),
      ));

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.fontSize, 16);
    });

    testWidgets('has rounded corners', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const TagChip(label: 'Test', color: Colors.green),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(20));
    });

    testWidgets('has bold font weight', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const TagChip(label: 'Test', color: Colors.orange),
      ));

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.fontWeight, FontWeight.w700);
    });
  });
}
