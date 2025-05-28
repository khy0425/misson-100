import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 접근성 관련 유틸리티 클래스
class AccessibilityUtils {
  AccessibilityUtils._();

  /// 스크린 리더를 위한 텍스트 포맷팅
  static String formatForScreenReader(String text) {
    // 숫자와 특수문자 사이에 공백 추가
    return text
        .replaceAll(RegExp(r'(\d)([가-힣])'), r'$1 $2')
        .replaceAll(RegExp(r'([가-힣])(\d)'), r'$1 $2')
        .replaceAll(':', ': ')
        .replaceAll('.', '. ')
        .replaceAll(',', ', ');
  }

  /// 진행률을 접근성 친화적으로 설명
  static String formatProgress(int current, int total) {
    final percentage = ((current / total) * 100).round();
    return '$total개 중 $current번째, $percentage퍼센트 완료';
  }

  /// 시간을 접근성 친화적으로 설명
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '$minutes분 $seconds초';
    } else {
      return '$seconds초';
    }
  }

  /// 햅틱 피드백 제공
  static void provideFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  /// 카드 레이블 생성
  static String createCardLabel({
    required String title,
    required String content,
    String? additionalInfo,
  }) {
    final buffer = StringBuffer();
    buffer.write('카드: ');
    buffer.write(formatForScreenReader(title));
    buffer.write('. ');
    buffer.write(formatForScreenReader(content));
    if (additionalInfo != null) {
      buffer.write('. ');
      buffer.write(formatForScreenReader(additionalInfo));
    }
    return buffer.toString();
  }

  /// 버튼 레이블 생성
  static String createButtonLabel({
    required String action,
    required String target,
    String? state,
    String? hint,
  }) {
    final buffer = StringBuffer();
    buffer.write('버튼: ');
    buffer.write(formatForScreenReader(action));
    buffer.write(' ');
    buffer.write(formatForScreenReader(target));
    if (state != null) {
      buffer.write('. ');
      buffer.write(formatForScreenReader(state));
    }
    if (hint != null) {
      buffer.write('. ');
      buffer.write(formatForScreenReader(hint));
    }
    return buffer.toString();
  }

  /// 접근성 공지사항 생성
  static void announceToScreenReader(BuildContext context, String message) {
    // Flutter의 Semantics 위젯을 통해 스크린 리더에 공지
    // 실제 구현에서는 context를 통해 접근성 서비스에 메시지 전달
    if (MediaQuery.of(context).accessibleNavigation) {
      // 접근성 모드가 활성화된 경우에만 실행
      // 향후 SemanticsService.announce 사용 가능
    }
  }

  /// 색상 대비 확인 (WCAG 2.1 기준)
  static bool hasGoodContrast(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    
    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    
    // WCAG AA 기준: 4.5:1 이상
    return contrastRatio >= 4.5;
  }



  /// 리스트 아이템 라벨 생성
  static String createListItemLabel({
    required String content,
    required int position,
    required int total,
    String? state,
  }) {
    final buffer = StringBuffer();
    buffer.write('$total개 중 $position번째 항목. $content');
    
    if (state != null) {
      buffer.write('. $state');
    }
    
    return formatForScreenReader(buffer.toString());
  }

  /// 폼 필드 라벨 생성
  static String createFormFieldLabel({
    required String label,
    bool isRequired = false,
    String? hint,
    String? error,
  }) {
    final buffer = StringBuffer();
    buffer.write(label);
    
    if (isRequired) {
      buffer.write(', 필수 입력');
    }
    
    if (hint != null) {
      buffer.write('. $hint');
    }
    
    if (error != null) {
      buffer.write('. 오류: $error');
    }
    
    return formatForScreenReader(buffer.toString());
  }

  /// 탭 라벨 생성
  static String createTabLabel({
    required String title,
    required int position,
    required int total,
    bool isSelected = false,
  }) {
    final buffer = StringBuffer();
    buffer.write('$total개 탭 중 $position번째. $title');
    
    if (isSelected) {
      buffer.write(', 선택됨');
    }
    
    return formatForScreenReader(buffer.toString());
  }

  /// 미디어 컨트롤 라벨 생성
  static String createMediaControlLabel({
    required String action,
    required String mediaType,
    String? currentState,
    String? duration,
  }) {
    final buffer = StringBuffer();
    buffer.write('$mediaType $action');
    
    if (currentState != null) {
      buffer.write(', 현재 상태: $currentState');
    }
    
    if (duration != null) {
      buffer.write(', 길이: $duration');
    }
    
    return formatForScreenReader(buffer.toString());
  }
}

/// 햅틱 피드백 타입 열거형
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
} 