import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/data/models/assessment_question_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../providers/assessment_provider.dart';
import 'dyslexia_assessment_page.dart';

class KinestheticAssessmentQuestionsPage extends StatefulWidget {
  const KinestheticAssessmentQuestionsPage({super.key});

  @override
  _KinestheticAssessmentQuestionsPageState createState() =>
      _KinestheticAssessmentQuestionsPageState();
}

class _KinestheticAssessmentQuestionsPageState
    extends State<KinestheticAssessmentQuestionsPage> {
  int currentQuestionIndex = 0;
  String? selectedAnswerId; // For letter_differentiation (stores optionId)
  List<String> droppedAnswers = []; // For letter_matching
  Map<String, String> matches = {}; // For number_letter_similarity
  List<MapEntry<String, String>> matchedPairs = [];
  Map<String, GlobalKey> optionKeys = {};
  Map<String, GlobalKey> matchKeys = {};
  final GlobalKey _customPaintKey = GlobalKey();
  bool isSubmitting = false; // Track submission state
  String? selectedLeftItem; // Track selected left item for matching

  void _initializeKeys(List<String>? options, List<String>? matches) {
    optionKeys.clear();
    matchKeys.clear();
    if (options != null) {
      for (int i = 0; i < options.length; i++) {
        String optionId = '${options[i]}_$i';
        optionKeys[optionId] = GlobalKey();
      }
    }
    if (matches != null) {
      for (int i = 0; i < matches.length; i++) {
        String matchId = '${matches[i]}_$i';
        matchKeys[matchId] = GlobalKey();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Kinesthetic Assessment',
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

        final kinestheticQuestions =
            provider.questions.where((q) => q.type == 'kinesthetic').toList();

        if (kinestheticQuestions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Kinesthetic Assessment',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body:
                const Center(child: Text('No kinesthetic questions available')),
          );
        }

        final currentQuestion = kinestheticQuestions[currentQuestionIndex];
        final questionType = currentQuestion.category;
        final isLastQuestion =
            currentQuestionIndex == kinestheticQuestions.length - 1;

        _initializeKeys(
          questionType == 'number_letter_similarity'
              ? currentQuestion.leftItems
              : currentQuestion.options,
          questionType == 'number_letter_similarity'
              ? currentQuestion.rightItems
              : null,
        );

        bool canProceed = questionType == 'letter_differentiation' &&
                selectedAnswerId != null ||
            questionType == 'number_letter_similarity' &&
                matches.length == (currentQuestion.leftItems?.length ?? 0) ||
            questionType == 'letter_matching' &&
                droppedAnswers.length ==
                    (currentQuestion.correctSequence?.length ?? 0);

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                questionType == 'letter_differentiation'
                    ? 'Letter Differentiation'
                    : questionType == 'number_letter_similarity'
                        ? 'Number & Letter Similarity'
                        : 'Letter Matching',
                style: const TextStyle(
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
                                      '${currentQuestionIndex + 1}/${kinestheticQuestions.length}',
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
                                      kinestheticQuestions.length,
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
                                  questionType == 'letter_differentiation'
                                      ? 'Drag the different letter to the box.'
                                      : questionType ==
                                              'number_letter_similarity'
                                          ? 'Match each letter/number by drawing a line.'
                                          : 'Drag the correct letters into the boxes to complete the word.',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildQuestionContent(
                                  currentQuestion,
                                  questionType,
                                  constraints.maxWidth,
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
                                ? () async {
                                    if (questionType ==
                                        'letter_differentiation') {
                                      // Extract actual answer from optionId
                                      final answer =
                                          selectedAnswerId!.split('_')[0];
                                      provider.addAnswer('kinesthetic',
                                          currentQuestion.id, answer);
                                    } else if (questionType ==
                                        'number_letter_similarity') {
                                      provider.addAnswer(
                                          'kinesthetic',
                                          currentQuestion.id,
                                          matches.entries
                                              .map((e) => {
                                                    'left': e.key,
                                                    'right': e.value
                                                  })
                                              .toList());
                                    } else if (questionType ==
                                        'letter_matching') {
                                      provider.addAnswer('kinesthetic',
                                          currentQuestion.id, droppedAnswers);
                                    }
                                    if (isLastQuestion) {
                                      setState(() {
                                        isSubmitting = true;
                                      });
                                      final navigator = Navigator.of(context);
                                      await provider
                                          .submitAnswers('kinesthetic');
                                      if (mounted) {
                                        navigator.pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const DyslexiaAssessmentPage(),
                                          ),
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        currentQuestionIndex++;
                                        selectedAnswerId = null;
                                        droppedAnswers = [];
                                        matches = {};
                                        matchedPairs = [];
                                        selectedLeftItem = null;
                                      });
                                    }
                                  }
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

  Widget _buildQuestionContent(AssessmentQuestionModel currentQuestion,
      String questionType, double maxWidth) {
    switch (questionType) {
      case 'letter_differentiation':
        // Calculate button size to fit 4-5 items per row
        final buttonSize = (maxWidth - 16 * 4) / 5; // 4 gaps of 16dp
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: currentQuestion.options!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final optionId = '${option}_$index';
                  if (selectedAnswerId == optionId) {
                    return Container(
                      width: buttonSize,
                      height: buttonSize,
                      color: Colors.grey[200],
                    );
                  }
                  return Draggable<String>(
                    data: optionId,
                    feedback: _buildOptionButton(option,
                        size: buttonSize, fontSize: 24),
                    childWhenDragging: Container(
                      width: buttonSize,
                      height: buttonSize,
                      color: Colors.grey[200],
                    ),
                    child: _buildOptionButton(
                      option,
                      id: optionId,
                      size: buttonSize,
                      fontSize: 24,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: selectedAnswerId != null
                        ? Center(
                            child: Text(
                              selectedAnswerId!.split('_')[0],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  );
                },
                onWillAcceptWithDetails: (data) => true,
                onAcceptWithDetails: (data) {
                  setState(() {
                    selectedAnswerId = data.data;
                  });
                },
              ),
            ),
          ],
        );
      case 'number_letter_similarity':
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
                              options: currentQuestion.leftItems!,
                              matches: currentQuestion.rightItems!,
                              constraints:
                                  BoxConstraints(maxWidth: maxWidth - 50),
                              customPaintRenderBox: _customPaintKey
                                  .currentContext
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
                                  children: currentQuestion.leftItems!
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final option = entry.value;
                                    final optionId = '${option}_$index';
                                    final isSelected =
                                        selectedLeftItem == option;
                                    return SizedBox(
                                      width: 120,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (matches.containsKey(option)) {
                                              // Remove the pair if already matched
                                              matches.remove(option);
                                              matchedPairs =
                                                  matches.entries.toList();
                                              selectedLeftItem = null;
                                            } else {
                                              // Select this item for matching
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
                                  children: currentQuestion.rightItems!
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final match = entry.value;
                                    final matchId = '${match}_$index';
                                    final isMatched =
                                        matches.containsValue(match);
                                    return SizedBox(
                                      width: 120,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (selectedLeftItem != null &&
                                              !isMatched) {
                                            setState(() {
                                              matches[selectedLeftItem!] =
                                                  match;
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
      case 'letter_matching':
        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (currentQuestion.imageURL != null)
                Center(
                  child: Image.network(
                    currentQuestion.imageURL!,
                    height: 150,
                    width: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'Image not found',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    currentQuestion.correctSequence!.length,
                    (index) => DragTarget<String>(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: candidateData.isNotEmpty
                                  ? AppColors.primary
                                  : Colors.grey,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: index < droppedAnswers.length
                              ? Center(
                                  child: Text(
                                    droppedAnswers[index],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                      onWillAcceptWithDetails: (data) => true,
                      onAcceptWithDetails: (data) {
                        setState(() {
                          if (index < droppedAnswers.length) {
                            // Replace existing answer
                            droppedAnswers[index] = data.data;
                          } else {
                            // Add new answer
                            droppedAnswers.add(data.data);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children:
                      currentQuestion.options!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final optionId = '${option}_$index';
                    if (droppedAnswers.contains(option)) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                      );
                    }
                    return Draggable<String>(
                      data: option,
                      feedback:
                          _buildOptionButton(option, size: 60, fontSize: 24),
                      childWhenDragging: Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                      ),
                      child: _buildOptionButton(
                        option,
                        id: optionId,
                        size: 60,
                        fontSize: 24,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      default:
        return const Center(child: Text('Unknown question type'));
    }
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

    for (var pair in pairs) {
      final left = pair.key;
      final right = pair.value;

      int leftIndex = options.indexOf(left);
      int rightIndex = matches.indexOf(right);
      String leftId = '${left}_$leftIndex';
      String rightId = '${right}_$rightIndex';

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
