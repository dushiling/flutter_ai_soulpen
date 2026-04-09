// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ai_soulpen/main.dart';

void main() {
  testWidgets('SoulPen app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const SoulPenApp());
    expect(find.text('文案生成'), findsOneWidget);
  });
}
