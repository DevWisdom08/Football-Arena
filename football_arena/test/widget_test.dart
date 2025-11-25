// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:football/main.dart';

void main() {
  testWidgets('Home screen renders core sections', (tester) async {
    await tester.pumpWidget(const FootballTriviaApp());

    expect(find.text('Game Modes'), findsOneWidget);
    expect(find.text('Daily Quiz'), findsOneWidget);
    expect(find.text('Play Now'), findsOneWidget);
    expect(find.text('Your Stats'), findsOneWidget);
    expect(find.text('Visit Store'), findsOneWidget);
  });
}
