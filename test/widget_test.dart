import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolla/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KollaApp());

    // Verify that the app starts
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
