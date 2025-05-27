import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission100_chad_pushup/main.dart';

void main() {
  testWidgets('Widget test', (WidgetTester tester) async {
    await tester.pumpWidget(MissionApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
