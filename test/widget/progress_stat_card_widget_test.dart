import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test용 ProgressStatCardWidget 클래스 (progress_tracking_screen.dart에서 private이므로 복사)
class ProgressStatCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const ProgressStatCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

void main() {
  group('ProgressStatCardWidget Tests', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('renders correctly with basic properties', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ProgressStatCardWidget(
          title: 'Total Time',
          value: '120min',
          icon: Icons.timer,
          color: Colors.blue,
        ),
      ));

      // Check if widget exists
      expect(find.byType(ProgressStatCardWidget), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      
      // Check if icon is displayed correctly
      expect(find.byIcon(Icons.timer), findsOneWidget);
      
      // Check if text is displayed correctly
      expect(find.text('120min'), findsOneWidget);
      expect(find.text('Total Time'), findsOneWidget);
    });

    testWidgets('displays different icons and values correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ProgressStatCardWidget(
          title: 'Completed Workouts',
          value: '45',
          icon: Icons.fitness_center,
          color: Colors.green,
        ),
      ));

      // Check if icon is displayed correctly
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      
      // Check if text is displayed correctly
      expect(find.text('45'), findsOneWidget);
      expect(find.text('Completed Workouts'), findsOneWidget);
      
      // Check Icon widget properties
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.fitness_center));
      expect(iconWidget.color, equals(Colors.green));
      expect(iconWidget.size, equals(28));
    });

    testWidgets('handles long titles and values correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ProgressStatCardWidget(
          title: 'Average Weekly Workout Time',
          value: '2 hours 30 minutes',
          icon: Icons.schedule,
          color: Colors.orange,
        ),
      ));

      expect(find.text('Average Weekly Workout Time'), findsOneWidget);
      expect(find.text('2 hours 30 minutes'), findsOneWidget);
      
      // Check text alignment
      final titleTextWidget = tester.widget<Text>(find.text('Average Weekly Workout Time'));
      expect(titleTextWidget.textAlign, equals(TextAlign.center));
      
      final valueTextWidget = tester.widget<Text>(find.text('2 hours 30 minutes'));
      expect(valueTextWidget.textAlign, equals(TextAlign.center));
    });

    testWidgets('applies different colors correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ProgressStatCardWidget(
          title: 'Streak',
          value: '1,250',
          icon: Icons.trending_up,
          color: Colors.red,
        ),
      ));

      // Check Icon color
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.trending_up));
      expect(iconWidget.color, equals(Colors.red));
      
      // Check Value text color
      final valueTextWidget = tester.widget<Text>(find.text('1,250'));
      expect(valueTextWidget.style?.color, equals(Colors.red));
    });

    testWidgets('container styling is applied correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ProgressStatCardWidget(
          title: 'Calories Burned',
          value: '2,400kcal',
          icon: Icons.local_fire_department,
          color: Colors.purple,
        ),
      ));

      // Check Container widget decoration properties
      final containerWidget = tester.widget<Container>(find.byType(Container));
      final decoration = containerWidget.decoration as BoxDecoration;
      
      expect(decoration.borderRadius, equals(BorderRadius.circular(12)));
      expect(decoration.border?.top.color, equals(Colors.purple.withValues(alpha: 0.3)));
      expect(decoration.border?.top.width, equals(1));
    });

    testWidgets('text styles are applied correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ProgressStatCardWidget(
          title: 'Consecutive Days',
          value: '7',
          icon: Icons.whatshot,
          color: Colors.amber,
        ),
      ));

      // Check Value text style
      final valueTextWidget = tester.widget<Text>(find.text('7'));
      expect(valueTextWidget.style?.fontSize, equals(18));
      expect(valueTextWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(valueTextWidget.style?.color, equals(Colors.amber));

      // Check Title text style
      final titleTextWidget = tester.widget<Text>(find.text('Consecutive Days'));
      expect(titleTextWidget.style?.fontSize, equals(12));
      expect(titleTextWidget.style?.fontWeight, equals(FontWeight.w500));
      expect(titleTextWidget.style?.color, equals(Colors.grey[600]));
    });
  });
} 