import 'package:flutter_test/flutter_test.dart';

// Unit Tests
import 'unit/models/progress_test.dart' as progress_tests;
import 'unit/models/user_profile_test.dart' as user_profile_tests;
import 'unit/models/workout_session_test.dart' as workout_session_tests;
import 'unit/models/achievement_test.dart' as achievement_tests;
import 'unit/models/challenge_test.dart' as challenge_tests;
import 'unit/models/chad_evolution_test.dart' as chad_evolution_model_tests;
import 'unit/models/workout_history_test.dart' as workout_history_tests;
import 'unit/services/progress_tracker_service_test.dart' as progress_tracker_tests;
import 'unit/services/chad_evolution_service_test.dart' as chad_evolution_service_tests;
import 'unit/services/database_service_test.dart' as database_service_tests;

// Integration Tests
import 'integration/progress_integration_test.dart' as progress_integration_tests;

// Widget Tests
import 'widget/achievement_progress_bar_test.dart' as achievement_progress_bar_test;
import 'widget/challenge_card_test.dart' as challenge_card_test;
import 'widget/simple_progress_bar_test.dart' as simple_progress_bar_test;
import 'widget/action_button_widget_test.dart' as action_button_widget_test;
import 'widget/description_container_widget_test.dart' as description_container_widget_test;
import 'widget/permission_icon_widget_test.dart' as permission_icon_widget_test;
import 'widget/progress_stat_card_widget_test.dart' as progress_stat_card_widget_test;
import 'widget/achievement_stat_widget_test.dart' as achievement_stat_widget_test;
import 'widget/rarity_badge_widget_test.dart' as rarity_badge_widget_test;
import 'widget/completed_badge_widget_test.dart' as completed_badge_widget_test;
import 'widget/connector_line_widget_test.dart' as connector_line_widget_test;
import 'widget/stat_item_widget_test.dart' as stat_item_widget_test;
import 'widget/circular_progress_widget_test.dart' as circular_progress_widget_test;

void main() {
  group('📊 Mission: 100 전체 테스트 스위트', () {
    group('📊 모델 테스트', () {
      progress_tests.main();
      user_profile_tests.main();
      workout_session_tests.main();
      achievement_tests.main();
      challenge_tests.main();
      chad_evolution_model_tests.main();
      workout_history_tests.main();
    });

    group('🔧 서비스 테스트', () {
      progress_tracker_tests.main();
      chad_evolution_service_tests.main();
      database_service_tests.main();
    });

    group('🔗 통합 테스트', () {
      progress_integration_tests.main();
    });

    group('🎨 위젯 테스트', () {
      achievement_progress_bar_test.main();
      challenge_card_test.main();
      simple_progress_bar_test.main();
      action_button_widget_test.main();
      description_container_widget_test.main();
      permission_icon_widget_test.main();
      progress_stat_card_widget_test.main();
      achievement_stat_widget_test.main();
      rarity_badge_widget_test.main();
      completed_badge_widget_test.main();
      connector_line_widget_test.main();
      stat_item_widget_test.main();
      circular_progress_widget_test.main();
    });
  });
} 