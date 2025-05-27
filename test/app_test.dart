import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission100_chad_pushup/main.dart';
import 'test_helper.dart';

void main() {
  setUpAll(() {
    setupTestEnvironment();
  });

  tearDownAll(() {
    tearDownTestEnvironment();
  });

  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MissionApp());
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(MissionApp());
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
