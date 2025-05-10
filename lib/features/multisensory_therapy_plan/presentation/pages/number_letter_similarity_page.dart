import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'therapy_results_page.dart';

class NumberLetterSimilarityPage extends StatefulWidget {
  const NumberLetterSimilarityPage({super.key});

  @override
  _NumberLetterSimilarityPageState createState() =>
      _NumberLetterSimilarityPageState();
}

class _NumberLetterSimilarityPageState
    extends State<NumberLetterSimilarityPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  Map<String, String> matches = {};
  Map<String, GlobalKey> optionKeys = {};
  Map<String, GlobalKey> matchKeys = {};
  List<MapEntry<String, String>> matchedPairs = [];
  final GlobalKey _customPaintKey = GlobalKey();

  final List<Map<String, dynamic>> questions = [
    {
      'type': 'number_letter_similarity',
      'title': 'Number & Letter Similarity',
      'instruction': 'Tap to match each letter/number with its pair.',
      'options': ['g', '4', 'q'],
      'matches': ['q', 'g', '4', 'A'],
      'correctAnswer': ['g-g', '4-4', 'q-q'],
    },
  ];

  int get totalQuestions => questions.length;

  @override
  void initState() {
    super.initState();
    _initializeKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _initializeKeys() {
    final currentQuestion = questions[currentQuestionIndex];
    optionKeys.clear();
    matchKeys.clear();

    final options = currentQuestion['options'] as List<String>;
    for (int i = 0; i < options.length; i++) {
      String option = options[i];
      String optionId = '${option}_$i';
      optionKeys[optionId] = GlobalKey();
    }

    final matches = currentQuestion['matches'] as List<String>;
    for (int i = 0; i < matches.length; i++) {
      String match = matches[i];
      String matchId = '${match}_$i';
      matchKeys[matchId] = GlobalKey();
    }
  }

  void handleMatchSelection(String option, String match) {
    setState(() {
      matches.removeWhere((key, value) => value == match);
      if (matches.containsKey(option)) {
        matches.remove(option);
      }
      matches[option] = match;
      matchedPairs = matches.entries.toList();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    });
  }

  void clearSelection(String option) {
    setState(() {
      if (matches.containsKey(option)) {
        matches.remove(option);
        matchedPairs = matches.entries.toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  Future<void> showAnswerFeedbackDialog({
    required BuildContext context,
    required bool isCorrect,
    required VoidCallback onProceed,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            onProceed();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCorrect ? 'Correct!' : 'Incorrect!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Image.asset(
                  isCorrect
                      ? AssetPath.iconCorrectAnswer
                      : AssetPath.iconWrongAnswer,
                  height: 80,
                  width: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 80,
                      color: isCorrect ? Colors.green : Colors.red,
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (!isCorrect && currentQuestionIndex < totalQuestions - 1)
                  const Text(
                    'That’s okay! Try the next one!',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  const Text(
                    "You're doing great!",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void proceedToNextQuestion() {
    final currentQuestion = questions[currentQuestionIndex];
    int correctMatches = 0;
    final correctAnswers = currentQuestion['correctAnswer'] as List<String>;

    for (var pair in matches.entries) {
      if (correctAnswers.contains('${pair.key}-${pair.value}')) {
        correctMatches++;
      }
    }

    bool isCorrect = correctMatches == matches.length &&
        correctMatches == correctAnswers.length;

    if (isCorrect) {
      score++;
    }

    void nextAction() {
      setState(() {
        if (currentQuestionIndex < totalQuestions - 1) {
          currentQuestionIndex++;
          matches = {};
          matchedPairs = [];
          _initializeKeys();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TherapyResultsPage(
                therapyType: 'Kinesthetic',
                score: score,
                totalQuestions: totalQuestions,
              ),
            ),
          );
        }
      });
    }

    showAnswerFeedbackDialog(
      context: context,
      isCorrect: isCorrect,
      onProceed: nextAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == totalQuestions - 1;
    final options = currentQuestion['options'] as List<String>;
    final matchesList = currentQuestion['matches'] as List<String>;

    bool canProceed = matches.length == options.length;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: AppColors.offWhite,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            currentQuestion['title'],
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QUESTION ${currentQuestionIndex + 1}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${currentQuestionIndex + 1}/$totalQuestions',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / totalQuestions,
                  backgroundColor: Colors.grey[300],
                  color: AppColors.primary,
                  minHeight: 8,
                ),
                const SizedBox(height: 24),
                Text(
                  'instruction :',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentQuestion['instruction'],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: 400,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                key: _customPaintKey,
                                painter: LinePainter(
                                  pairs: matchedPairs,
                                  optionKeys: optionKeys,
                                  matchKeys: matchKeys,
                                  options: options,
                                  matches: matchesList,
                                  constraints: const BoxConstraints(),
                                  customPaintRenderBox: _customPaintKey
                                      .currentContext
                                      ?.findRenderObject() as RenderBox?,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        options.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final option = entry.value;
                                      final optionId = '${option}_$index';

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: GestureDetector(
                                          onTap: () => clearSelection(option),
                                          child: _buildOptionButton(
                                            option,
                                            isSelected:
                                                matches.containsKey(option),
                                            id: optionId,
                                            key: optionKeys[optionId],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: matchesList
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final match = entry.value;
                                      final matchId = '${match}_$index';

                                      bool isMatched =
                                          matches.containsValue(match);

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: GestureDetector(
                                          onTap: () {
                                            final unmatched =
                                                options.firstWhere(
                                              (opt) =>
                                                  !matches.containsKey(opt),
                                              orElse: () => '',
                                            );

                                            if (unmatched.isNotEmpty &&
                                                !isMatched) {
                                              handleMatchSelection(
                                                  unmatched, match);
                                            }
                                          },
                                          child: _buildOptionButton(
                                            match,
                                            isSelected: isMatched,
                                            id: matchId,
                                            key: matchKeys[matchId],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: !canProceed
                        ? Colors.grey[300]!.withOpacity(0.6)
                        : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(-2, -4),
                        blurRadius: 4,
                        color: AppColors.grey.withOpacity(0.7),
                        inset: true,
                      ),
                      if (canProceed)
                        BoxShadow(
                          offset: const Offset(2, 4),
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.1),
                          inset: false,
                        ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: canProceed ? proceedToNextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastQuestion ? 'Finish' : 'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: !canProceed
                                ? Colors.grey[600]
                                : AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color:
                              !canProceed ? Colors.grey[600] : AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String text,
      {bool isSelected = false, String? id, Key? key}) {
    return Container(
      key: key,
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color:
            isSelected ? AppColors.primary.withOpacity(0.2) : Colors.grey[200],
        border:
            isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (isSelected)
            const Positioned(
              top: 2,
              right: 2,
              child: Icon(
                Icons.check,
                size: 16,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final List<MapEntry<String, String>> pairs;
  final Map<String, GlobalKey> optionKeys;
  final Map<String, GlobalKey> matchKeys;
  final List<String> options;
  final List<String> matches;
  final BoxConstraints constraints;
  final RenderBox? customPaintRenderBox;

  LinePainter({
    required this.pairs,
    required this.optionKeys,
    required this.matchKeys,
    required this.options,
    required this.matches,
    required this.constraints,
    required this.customPaintRenderBox,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (customPaintRenderBox == null) return;

    for (var pair in pairs) {
      final option = pair.key;
      final match = pair.value;

      GlobalKey? optionKey;
      GlobalKey? matchKey;

      for (var entry in optionKeys.entries) {
        if (entry.key.startsWith('${option}_')) {
          optionKey = entry.value;
          break;
        }
      }

      for (var entry in matchKeys.entries) {
        if (entry.key.startsWith('${match}_')) {
          matchKey = entry.value;
          break;
        }
      }

      if (optionKey != null && matchKey != null) {
        final RenderBox? optionRenderBox =
            optionKey.currentContext?.findRenderObject() as RenderBox?;
        final RenderBox? matchRenderBox =
            matchKey.currentContext?.findRenderObject() as RenderBox?;

        if (optionRenderBox != null && matchRenderBox != null) {
          try {
            final optionPos = optionRenderBox.localToGlobal(Offset.zero);
            final matchPos = matchRenderBox.localToGlobal(Offset.zero);

            final painterPos = customPaintRenderBox!.localToGlobal(Offset.zero);

            final optionRelativePos = Offset(
              optionPos.dx - painterPos.dx + optionRenderBox.size.width,
              optionPos.dy - painterPos.dy + optionRenderBox.size.height / 2,
            );

            final matchRelativePos = Offset(
              matchPos.dx - painterPos.dx,
              matchPos.dy - painterPos.dy + matchRenderBox.size.height / 2,
            );

            canvas.drawLine(optionRelativePos, matchRelativePos, paint);
          } catch (e) {
            print('Error drawing line: $e');
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
