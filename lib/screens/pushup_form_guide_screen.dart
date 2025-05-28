import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/pushup_form_guide.dart';
import '../services/pushup_form_guide_service.dart';
import '../services/chad_encouragement_service.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/video_player_widget.dart';
import '../utils/accessibility_utils.dart';

class PushupFormGuideScreen extends StatefulWidget {
  const PushupFormGuideScreen({super.key});

  @override
  State<PushupFormGuideScreen> createState() => _PushupFormGuideScreenState();
}

class _PushupFormGuideScreenState extends State<PushupFormGuideScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formGuideService = PushupFormGuideService();
  final _encouragementService = ChadEncouragementService();
  late PushupFormGuideData _guideData;
  
  // 인터랙티브 요소들을 위한 상태 변수
  final PageController _stepPageController = PageController();
  int _currentStepIndex = 0;
  bool _isStepViewMode = false;
  final Map<int, bool> _expandedCards = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _guideData = _formGuideService.getFormGuideData();

    // 화면 로드 후 격려 메시지 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _encouragementService.maybeShowEncouragement(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stepPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenHeight < 700;
    final adHeight = isSmallScreen ? 50.0 : 60.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        title: const Text(
          '완벽한 푸시업 자세',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4DABF7),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4DABF7),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: [
            Semantics(
              label: AccessibilityUtils.createTabLabel(
                title: '단계별 가이드',
                position: 1,
                total: 4,
                isSelected: _tabController.index == 0,
              ),
              child: const Tab(text: '단계별\n가이드'),
            ),
            Semantics(
              label: AccessibilityUtils.createTabLabel(
                title: '일반적인 실수',
                position: 2,
                total: 4,
                isSelected: _tabController.index == 1,
              ),
              child: const Tab(text: '일반적인\n실수'),
            ),
            Semantics(
              label: AccessibilityUtils.createTabLabel(
                title: '변형 운동',
                position: 3,
                total: 4,
                isSelected: _tabController.index == 2,
              ),
              child: const Tab(text: '변형\n운동'),
            ),
            Semantics(
              label: AccessibilityUtils.createTabLabel(
                title: '개선 팁',
                position: 4,
                total: 4,
                isSelected: _tabController.index == 3,
              ),
              child: const Tab(text: '개선\n팁'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 메인 컨텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFormStepsTab(),
                _buildCommonMistakesTab(),
                _buildVariationsTab(),
                _buildImprovementTipsTab(),
              ],
            ),
          ),

          // 하단 배너 광고 (테스트 환경에서는 숨김)
          if (!kDebugMode) _buildResponsiveBannerAd(context, adHeight),
        ],
      ),
    );
  }

  Widget _buildFormStepsTab() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // 헤더와 컨트롤
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 헤더
                _buildSectionHeader(
                  '올바른 푸시업 자세 5단계',
                  '차드가 알려주는 완벽한 푸시업 폼! 💪',
                  Icons.fitness_center,
                  const Color(0xFF4DABF7),
                ),
                
                const SizedBox(height: 16),
                
                // 뷰 모드 전환 버튼들
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: AccessibilityUtils.createButtonLabel(
                          action: '목록 보기로 전환',
                          target: '단계별 가이드',
                          state: !_isStepViewMode ? '현재 선택됨' : null,
                          hint: '단계별 가이드를 목록 형태로 표시합니다',
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => _isStepViewMode = false),
                          icon: const Icon(Icons.list, size: 18),
                          label: const Text('목록 보기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_isStepViewMode 
                                ? const Color(0xFF4DABF7) 
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: AccessibilityUtils.createButtonLabel(
                          action: '스와이프 보기로 전환',
                          target: '단계별 가이드',
                          state: _isStepViewMode ? '현재 선택됨' : null,
                          hint: '단계별 가이드를 스와이프 형태로 표시합니다',
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => _isStepViewMode = true),
                          icon: const Icon(Icons.swipe, size: 18),
                          label: const Text('스와이프 보기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isStepViewMode 
                                ? const Color(0xFF4DABF7) 
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Semantics(
                      button: true,
                      label: AccessibilityUtils.createButtonLabel(
                        action: '퀴즈 시작',
                        target: '푸시업 폼 가이드',
                        hint: '학습한 내용을 확인하는 퀴즈를 시작합니다',
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _showQuiz,
                        icon: const Icon(Icons.quiz, size: 18),
                        label: const Text('퀴즈'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF51CF66),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 컨텐츠 영역
          Expanded(
            child: _isStepViewMode 
                ? _buildSwipeableStepsView()
                : _buildListStepsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonMistakesTab() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildSectionHeader(
              '이런 실수는 하지 마라!',
              '차드도 처음엔 실수했다. 하지만 이제는 완벽하지! 🔥',
              Icons.warning,
              const Color(0xFFFF6B6B),
            ),

            const SizedBox(height: 20),

            // 실수 목록
            ...List.generate(_guideData.commonMistakes.length, (index) {
              final mistake = _guideData.commonMistakes[index];
              return _buildCommonMistakeCard(mistake, index == _guideData.commonMistakes.length - 1);
            }),

            const SizedBox(height: 80), // 광고 공간 확보
          ],
        ),
      ),
    );
  }

  Widget _buildVariationsTab() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildSectionHeader(
              '난이도별 푸시업 변형',
              '초보자부터 차드까지! 단계별로 도전해보자! 🚀',
              Icons.trending_up,
              const Color(0xFF51CF66),
            ),

            const SizedBox(height: 20),

            // 난이도별 그룹핑
            ..._buildVariationsByDifficulty(),

            const SizedBox(height: 80), // 광고 공간 확보
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementTipsTab() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildSectionHeader(
              '차드의 특급 비법',
              '이 팁들로 너도 진짜 차드가 될 수 있다! 💎',
              Icons.lightbulb,
              const Color(0xFFFFD43B),
            ),

            const SizedBox(height: 20),

            // 개선 팁들
            ...List.generate(_guideData.improvementTips.length, (index) {
              final tip = _guideData.improvementTips[index];
              return _buildImprovementTipCard(tip, index == _guideData.improvementTips.length - 1);
            }),

            const SizedBox(height: 80), // 광고 공간 확보
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Semantics(
      header: true,
      label: '$title. $subtitle',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Semantics(
              excludeSemantics: true,
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 나머지 메서드들은 다음 단계에서 추가하겠습니다
  Widget _buildCommonMistakeCard(CommonMistake mistake, bool isLast) {
    final severityColor = Color(PushupFormGuideService.getSeverityColor(mistake.severity));
    final corrections = mistake.corrections.join(', ');

    return Semantics(
      label: AccessibilityUtils.createCardLabel(
        title: mistake.title,
        content: mistake.description,
        additionalInfo: '심각도: ${mistake.severity}. 교정 방법: $corrections',
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
        child: Card(
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: severityColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목과 심각도
                Row(
                  children: [
                    Semantics(
                      label: '경고 아이콘',
                      child: Icon(
                        Icons.warning,
                        color: severityColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mistake.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Semantics(
                      label: '심각도 ${mistake.severity}',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mistake.severity.toUpperCase(),
                          style: TextStyle(
                            color: severityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 설명
                Text(
                  mistake.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // 잘못된 자세 vs 올바른 자세 이미지
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFF6B6B), width: 1),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close,
                                  color: Color(0xFFFF6B6B),
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '잘못된 자세',
                                  style: TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF51CF66), width: 1),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Color(0xFF51CF66),
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '올바른 자세',
                                  style: TextStyle(
                                    color: Color(0xFF51CF66),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 교정 방법
                const Text(
                  '교정 방법:',
                  style: TextStyle(
                    color: Color(0xFF51CF66),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...mistake.corrections.map((correction) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✓ ',
                        style: TextStyle(
                          color: Color(0xFF51CF66),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          correction,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVariationsByDifficulty() {
    final groupedVariations = <String, List<PushupVariation>>{};
    
    for (final variation in _guideData.variations) {
      groupedVariations.putIfAbsent(variation.difficulty, () => []).add(variation);
    }

    final difficulties = ['beginner', 'intermediate', 'advanced'];
    final difficultyNames = {
      'beginner': '초급자',
      'intermediate': '중급자',
      'advanced': '고급자',
    };

    return difficulties.expand((difficulty) {
      final variations = groupedVariations[difficulty] ?? [];
      if (variations.isEmpty) return <Widget>[];

      final difficultyColor = Color(PushupFormGuideService.getDifficultyColor(difficulty));

      return [
        // 난이도 제목
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.star, color: difficultyColor, size: 20),
              const SizedBox(width: 8),
              Text(
                difficultyNames[difficulty] ?? difficulty,
                style: TextStyle(
                  color: difficultyColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // 변형 운동들
        ...variations.map((variation) => _buildVariationCard(variation)),

        const SizedBox(height: 20),
      ];
    }).toList();
  }

  Widget _buildVariationCard(PushupVariation variation) {
    final difficultyColor = Color(PushupFormGuideService.getDifficultyColor(variation.difficulty));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: difficultyColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목과 난이도
              Row(
                children: [
                  Expanded(
                    child: Text(
                      variation.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: difficultyColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      variation.difficulty.toUpperCase(),
                      style: TextStyle(
                        color: difficultyColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 설명
              Text(
                variation.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              // 이미지 플레이스홀더
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: difficultyColor, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: difficultyColor,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '운동 이미지',
                      style: TextStyle(
                        color: difficultyColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 실행 방법
              const Text(
                '실행 방법:',
                style: TextStyle(
                  color: Color(0xFF4DABF7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ...variation.instructions.map((instruction) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        color: Color(0xFF4DABF7),
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        instruction,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 8),

              // 효과
              const Text(
                '효과:',
                style: TextStyle(
                  color: Color(0xFF51CF66),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ...variation.benefits.map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✓ ',
                      style: TextStyle(
                        color: Color(0xFF51CF66),
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImprovementTipCard(ImprovementTip tip, bool isLast) {
    final categoryColors = {
      '호흡법': const Color(0xFF4DABF7),
      '근력 향상': const Color(0xFF51CF66),
      '회복': const Color(0xFFFFD43B),
      '동기부여': const Color(0xFFFF6B6B),
    };

    final categoryColor = categoryColors[tip.category] ?? const Color(0xFF4DABF7);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Card(
        color: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: categoryColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리와 제목
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tip.category,
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                tip.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // 설명
              Text(
                tip.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              // 실행 항목들
              const Text(
                '실행 방법:',
                style: TextStyle(
                  color: Color(0xFF4DABF7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...tip.actionItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 ',
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListStepsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 단계별 가이드
          ...List.generate(_guideData.formSteps.length, (index) {
            final step = _guideData.formSteps[index];
            return _buildExpandableFormStepCard(step, index);
          }),
          const SizedBox(height: 80), // 광고 공간 확보
        ],
      ),
    );
  }

  Widget _buildSwipeableStepsView() {
    return Column(
      children: [
        // 진행률 표시기
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Semantics(
            label: AccessibilityUtils.formatProgress(
              _currentStepIndex + 1,
              _guideData.formSteps.length,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '단계 ${_currentStepIndex + 1} / ${_guideData.formSteps.length}',
                      style: const TextStyle(
                        color: Color(0xFF4DABF7),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '좌우로 스와이프하세요',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Semantics(
                  excludeSemantics: true,
                  child: LinearProgressIndicator(
                    value: (_currentStepIndex + 1) / _guideData.formSteps.length,
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4DABF7)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 스와이프 가능한 단계별 가이드
        Expanded(
          child: PageView.builder(
            controller: _stepPageController,
            onPageChanged: (index) {
              setState(() {
                _currentStepIndex = index;
              });
            },
            itemCount: _guideData.formSteps.length,
            itemBuilder: (context, index) {
              final step = _guideData.formSteps[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFormStepCard(step, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableFormStepCard(FormStep step, int index) {
    final isExpanded = _expandedCards[index] ?? false;
    
    return Semantics(
      label: AccessibilityUtils.createCardLabel(
        title: '단계 ${index + 1}: ${step.title}',
        content: step.description,
        additionalInfo: isExpanded ? '확장됨' : '축소됨. 탭하여 확장',
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Card(
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF4DABF7), width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _expandedCards[index] = !isExpanded;
              });
              AccessibilityUtils.provideFeedback(HapticFeedbackType.selectionClick);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 단계 번호와 제목
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4DABF7),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: const Color(0xFF4DABF7),
                        size: 24,
                      ),
                    ],
                  ),

                  if (isExpanded) ...[
                    const SizedBox(height: 16),
                    
                    // 설명
                    Text(
                      step.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 미디어 컨텐츠 (비디오 또는 이미지)
                    _buildMediaContent(step),

                    const SizedBox(height: 16),

                    // 주요 포인트
                    if (step.keyPoints.isNotEmpty) ...[
                      const Text(
                        '주요 포인트:',
                        style: TextStyle(
                          color: Color(0xFF4DABF7),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...step.keyPoints.map((point) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: Color(0xFF4DABF7),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormStepCard(FormStep step, int index) {
    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF4DABF7), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 단계 번호와 제목
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4DABF7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      step.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 설명
              Text(
                step.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // 미디어 컨텐츠
              _buildMediaContent(step),

              const SizedBox(height: 20),

              // 주요 포인트
              if (step.keyPoints.isNotEmpty) ...[
                const Text(
                  '주요 포인트:',
                  style: TextStyle(
                    color: Color(0xFF4DABF7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...step.keyPoints.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          color: Color(0xFF4DABF7),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent(FormStep step) {
    // 비디오가 있으면 비디오 플레이어 표시
    if (step.videoUrl != null && step.videoUrl!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: '${step.title} 시연 비디오',
            child: VideoPlayerWidget(
              videoUrl: step.videoUrl!,
              autoPlay: false,
              showControls: true,
            ),
          ),
          if (step.videoDescription != null && step.videoDescription!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              step.videoDescription!,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      );
    }

    // 비디오가 없으면 이미지 플레이스홀더 표시
    return Semantics(
      label: '${step.title} 자세 이미지 플레이스홀더',
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4DABF7), width: 1),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              color: Color(0xFF4DABF7),
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              '자세 이미지',
              style: TextStyle(
                color: Color(0xFF4DABF7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuiz() {
    final quizQuestions = _guideData.quizQuestions;
    if (quizQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('퀴즈 데이터를 불러올 수 없습니다.'),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _QuizDialog(
        questions: quizQuestions,
        onCompleted: (result) {
          _showQuizResult(result);
        },
      ),
    );
  }

  void _showQuizResult(QuizResult result) {
    final isPassed = result.scorePercentage >= 70;
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isPassed ? const Color(0xFF51CF66) : const Color(0xFFFF6B6B),
            width: 2,
          ),
        ),
        title: Row(
          children: [
            Icon(
              isPassed ? Icons.check_circle : Icons.cancel,
              color: isPassed ? const Color(0xFF51CF66) : const Color(0xFFFF6B6B),
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              isPassed ? '퀴즈 통과!' : '다시 도전!',
              style: TextStyle(
                color: isPassed ? const Color(0xFF51CF66) : const Color(0xFFFF6B6B),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '점수: ${result.correctAnswers}/${result.totalQuestions} (${result.scorePercentage.round()}%)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPassed 
                  ? '축하합니다! 푸시업 폼에 대해 잘 이해하고 계시네요! 💪'
                  : '70% 이상 맞춰야 통과입니다. 가이드를 다시 읽어보고 도전해보세요! 📚',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '확인',
              style: TextStyle(color: Color(0xFF4DABF7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveBannerAd(BuildContext context, double adHeight) {
    return Container(
      height: adHeight,
      color: const Color(0xFF0D0D0D),
      child: const SafeArea(
        top: false,
        child: AdBannerWidget(),
      ),
    );
  }
}

/// 퀴즈 다이얼로그 위젯
class _QuizDialog extends StatefulWidget {
  final List<QuizQuestion> questions;
  final void Function(QuizResult) onCompleted;

  const _QuizDialog({
    required this.questions,
    required this.onCompleted,
  });

  @override
  State<_QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<_QuizDialog> {
  int _currentQuestionIndex = 0;
  final List<int?> _selectedAnswers = [];
  final List<bool> _answerResults = [];

  @override
  void initState() {
    super.initState();
    // 답변 배열 초기화
    for (int i = 0; i < widget.questions.length; i++) {
      _selectedAnswers.add(null);
      _answerResults.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.questions.length;

    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF4DABF7), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                const Icon(
                  Icons.quiz,
                  color: Color(0xFF4DABF7),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  '푸시업 폼 퀴즈',
                  style: TextStyle(
                    color: Color(0xFF4DABF7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentQuestionIndex + 1}/${widget.questions.length}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 진행률 표시기
            Semantics(
              label: AccessibilityUtils.formatProgress(
                _currentQuestionIndex + 1,
                widget.questions.length,
              ),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4DABF7)),
              ),
            ),

            const SizedBox(height: 20),

            // 질문
            Text(
              currentQuestion.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // 선택지들
            ...List.generate(currentQuestion.options.length, (index) {
              final isSelected = _selectedAnswers[_currentQuestionIndex] == index;
              
              return Semantics(
                button: true,
                label: AccessibilityUtils.createButtonLabel(
                  action: '선택',
                  target: currentQuestion.options[index],
                  state: isSelected ? '선택됨' : null,
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _selectedAnswers[_currentQuestionIndex] = index;
                      });
                      AccessibilityUtils.provideFeedback(HapticFeedbackType.selectionClick);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF4DABF7).withValues(alpha: 0.2)
                            : const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF4DABF7)
                              : Colors.grey.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected 
                                  ? const Color(0xFF4DABF7)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF4DABF7)
                                    : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                                                 ? const Icon(
                                     Icons.check,
                                     color: Colors.white,
                                     size: 12,
                                   )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentQuestion.options[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // 버튼들
            Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      child: const Text(
                        '이전',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedAnswers[_currentQuestionIndex] != null
                        ? () {
                            if (_currentQuestionIndex < widget.questions.length - 1) {
                              // 다음 질문으로
                              setState(() {
                                _currentQuestionIndex++;
                              });
                            } else {
                              // 퀴즈 완료
                              _completeQuiz();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DABF7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _currentQuestionIndex < widget.questions.length - 1
                          ? '다음'
                          : '완료',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _completeQuiz() {
    // 정답 확인
    int correctAnswers = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      final isCorrect = _selectedAnswers[i] == widget.questions[i].correctAnswerIndex;
      _answerResults[i] = isCorrect;
      if (isCorrect) correctAnswers++;
    }

    // 결과 생성
    final result = QuizResult(
      totalQuestions: widget.questions.length,
      correctAnswers: correctAnswers,
      answerResults: _answerResults,
      scorePercentage: (correctAnswers / widget.questions.length) * 100,
    );

    // 다이얼로그 닫기
    Navigator.of(context).pop();

    // 결과 콜백 호출
    widget.onCompleted(result);
  }
} 