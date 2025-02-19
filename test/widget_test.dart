import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vista_frontend/app/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VistaApp());

    // Verify that our app starts with a scaffold
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
