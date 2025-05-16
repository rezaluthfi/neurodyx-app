import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/providers/therapy_provider.dart';
import '../therapy_results_page.dart';

class NumberLetterSimilarityPage extends StatefulWidget {
  final String category;
  const NumberLetterSimilarityPage({super.key, required this.category});

  @override
  _NumberLetterSimilarityPageState createState() =>
      _NumberLetterSimilarityPageState();
}

class _NumberLetterSimilarityPageState
    extends State<NumberLetterSimilarityPage> {
  int currentQuestionIndex = 0;
  String? selectedLeftItem;
  Map<String, String> matches = {};
  List<MapEntry<String, String>> matchedPairs = [];
  Map<String, GlobalKey> optionKeys = {};
  Map<String, GlobalKey> matchKeys = {};
  final GlobalKey _customPaintKey = GlobalKey();
  bool isSubmitting = false;
  ScaffoldMessengerState? _scaffoldMessenger;
  // Store navigator state to avoid context issues
  NavigatorState? _navigator;

  void _initializeKeys(List<String> leftItems, List<String> rightItems) {
    optionKeys.clear();
    matchKeys.clear();
    for (int i = 0; i < leftItems.length; i++) {
      String optionId = 'left_${leftItems[i]}_$i';
      optionKeys[optionId] = GlobalKey();
    }
    for (int i = 0; i < rightItems.length; i++) {
      String matchId = 'right_${rightItems[i]}_$i';
      matchKeys[matchId] = GlobalKey();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    // Store navigator reference safely
    _navigator = Navigator.of(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TherapyProvider>(context, listen: false)
          .fetchQuestions('kinesthetic', widget.category);
    });
  }

  // Method to safely navigate to the results page
  void _navigateToResultsPage() {
    if (_navigator != null && mounted) {
      debugPrint('Navigating to TherapyResultsPage');
      _navigator!.pushReplacement(
        MaterialPageRoute(
          builder: (context) => TherapyResultsPage(
            therapyType: 'Kinesthetic',
            category: widget.category,
          ),
        ),
      );
      debugPrint('Navigation request sent');
    } else {
      debugPrint('Navigation failed - navigator is null or widget not mounted');
    }
  }

  // Method to handle submitting answers and navigation
  Future<void> _handleSubmitAndNavigate(
      TherapyProvider provider, dynamic currentQuestion) async {
    final answerPairs =
        matches.entries.map((e) => '${e.key}-${e.value}').toList()..sort();
    final answer = answerPairs.join(',');

    try {
      provider.addAnswer('kinesthetic', currentQuestion.id, answer);
      debugPrint('Answer added successfully');

      // Check if this is the last question
      final isLastQuestion =
          currentQuestionIndex == provider.questions.length - 1;

      if (!isLastQuestion) {
        if (mounted) {
          setState(() {
            currentQuestionIndex++;
            matches = {};
            matchedPairs = [];
            selectedLeftItem = null;
          });
        }
        return;
      }

      // This is the last question, submit answers and navigate
      if (mounted) {
        setState(() {
          isSubmitting = true;
        });
      }

      try {
        await provider.submitAnswers('kinesthetic', widget.category);
        debugPrint('Answers submitted successfully');

        // Use a small delay to allow state to settle
        await Future.delayed(const Duration(milliseconds: 300));

        // Navigate to results page using our safe method
        _navigateToResultsPage();
      } catch (e, stackTrace) {
        debugPrint('Error in submitAnswers: $e\n$stackTrace');
        if (mounted) {
          _scaffoldMessenger?.showSnackBar(
            SnackBar(content: Text('Error submitting answers: $e')),
          );
          setState(() => isSubmitting = false);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error in addAnswer: $e\n$stackTrace');
      if (mounted) {
        _scaffoldMessenger?.showSnackBar(
          SnackBar(content: Text('Error adding answer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TherapyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Number & Letter Similarity',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: Shimmer.fromColors(
                baseColor: AppColors.grey.withOpacity(0.2),
                highlightColor: AppColors.grey.withOpacity(0.1),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 120,
                        color: AppColors.white,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 24,
                        color: AppColors.white,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        height: 48,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (provider.questions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Number & Letter Similarity',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: const Center(child: Text('No questions available')),
          );
        }

        final currentQuestion = provider.questions[currentQuestionIndex];
        final isLastQuestion =
            currentQuestionIndex == provider.questions.length - 1;

        // Use leftItems and rightItems from the API response
        final leftItems = currentQuestion.leftItems ?? [];
        final rightItems = currentQuestion.rightItems ?? [];
        final correctPairs = currentQuestion.correctPairs ?? {};

        _initializeKeys(leftItems, rightItems);
        // Check if all items that need to be matched have been matched
        bool canProceed = matches.length == correctPairs.length;

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(
                'Number & Letter Similarity',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isSubmitting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      '${currentQuestionIndex + 1}/${provider.questions.length}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: (currentQuestionIndex + 1) /
                                      provider.questions.length,
                                  backgroundColor: Colors.grey[300],
                                  color: AppColors.primary,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(8),
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
                                  currentQuestion.description ??
                                      'Match each letter/number by drawing a line.',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildQuestionContent(
                                  currentQuestion,
                                  constraints.maxWidth,
                                  leftItems,
                                  rightItems,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: !canProceed || isSubmitting
                                ? Colors.grey[300]!.withOpacity(0.6)
                                : AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(-2, -4),
                                blurRadius: 4,
                                color: AppColors.grey.withOpacity(0.7),
                                inset: true,
                              ),
                              if (canProceed && !isSubmitting)
                                BoxShadow(
                                  offset: const Offset(2, 4),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.1),
                                  inset: false,
                                ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: canProceed && !isSubmitting
                                ? () => _handleSubmitAndNavigate(
                                    provider, currentQuestion)
                                : null,
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
                                    color: !canProceed || isSubmitting
                                        ? Colors.grey[600]
                                        : AppColors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLastQuestion
                                      ? Icons.check
                                      : Icons.arrow_forward,
                                  size: 20,
                                  color: !canProceed || isSubmitting
                                      ? Colors.grey[600]
                                      : AppColors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionContent(
    dynamic currentQuestion,
    double maxWidth,
    List<String> leftItems,
    List<String> rightItems,
  ) {
    if (leftItems.isEmpty || rightItems.isEmpty) {
      return const Center(
        child: Text(
          'No options available',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxWidth * 1.2),
          child: SingleChildScrollView(
            child: SizedBox(
              width: maxWidth - 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        key: _customPaintKey,
                        painter: LinePainter(
                          pairs: matchedPairs,
                          optionKeys: optionKeys,
                          matchKeys: matchKeys,
                          leftItems: leftItems,
                          rightItems: rightItems,
                          constraints: BoxConstraints(maxWidth: maxWidth - 50),
                          customPaintRenderBox: _customPaintKey.currentContext
                              ?.findRenderObject() as RenderBox?,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 16,
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: leftItems.asMap().entries.map((entry) {
                                final index = entry.key;
                                final option = entry.value;
                                final optionId = 'left_${option}_$index';
                                final isSelected = selectedLeftItem == option;
                                return SizedBox(
                                  width: 120,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (matches.containsKey(option)) {
                                          matches.remove(option);
                                          matchedPairs =
                                              matches.entries.toList();
                                          selectedLeftItem = null;
                                        } else {
                                          selectedLeftItem = option;
                                        }
                                      });
                                    },
                                    child: _buildOptionButton(
                                      option,
                                      isSelected: isSelected ||
                                          matches.containsKey(option),
                                      id: optionId,
                                      key: optionKeys[optionId],
                                      size: 48,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 16,
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: rightItems.asMap().entries.map((entry) {
                                final index = entry.key;
                                final match = entry.value;
                                final matchId = 'right_${match}_$index';
                                final isMatched = matches.containsValue(match);
                                return SizedBox(
                                  width: 120,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (selectedLeftItem != null &&
                                          !isMatched) {
                                        setState(() {
                                          matches[selectedLeftItem!] = match;
                                          matchedPairs =
                                              matches.entries.toList();
                                          selectedLeftItem = null;
                                        });
                                      }
                                    },
                                    child: _buildOptionButton(
                                      match,
                                      isSelected: isMatched,
                                      id: matchId,
                                      key: matchKeys[matchId],
                                      size: 48,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
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
      ),
    );
  }

  Widget _buildOptionButton(
    String text, {
    bool isSelected = false,
    String? id,
    Key? key,
    required double size,
    required double fontSize,
  }) {
    return Container(
      key: key,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.greenMint,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.greenMint,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final List<MapEntry<String, String>> pairs;
  final Map<String, GlobalKey> optionKeys;
  final Map<String, GlobalKey> matchKeys;
  final List<String> leftItems;
  final List<String> rightItems;
  final BoxConstraints constraints;
  final RenderBox? customPaintRenderBox;

  LinePainter({
    required this.pairs,
    required this.optionKeys,
    required this.matchKeys,
    required this.leftItems,
    required this.rightItems,
    required this.constraints,
    required this.customPaintRenderBox,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var pair in pairs) {
      final left = pair.key;
      final right = pair.value;

      int leftIndex = leftItems.indexOf(left);
      int rightIndex = rightItems.indexOf(right);
      String leftId = 'left_${left}_$leftIndex';
      String rightId = 'right_${right}_$rightIndex';

      final leftKey = optionKeys[leftId];
      final rightKey = matchKeys[rightId];

      if (leftKey != null && rightKey != null) {
        final leftContext = leftKey.currentContext;
        final rightContext = rightKey.currentContext;

        if (leftContext != null && rightContext != null) {
          final leftRenderBox = leftContext.findRenderObject() as RenderBox?;
          final rightRenderBox = rightContext.findRenderObject() as RenderBox?;

          if (leftRenderBox != null && rightRenderBox != null) {
            final leftOffset = leftRenderBox.localToGlobal(Offset.zero,
                ancestor: customPaintRenderBox);
            final rightOffset = rightRenderBox.localToGlobal(Offset.zero,
                ancestor: customPaintRenderBox);

            final leftCenter = leftOffset +
                Offset(leftRenderBox.size.width / 2,
                    leftRenderBox.size.height / 2);
            final rightCenter = rightOffset +
                Offset(rightRenderBox.size.width / 2,
                    rightRenderBox.size.height / 2);

            canvas.drawLine(leftCenter, rightCenter, paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
