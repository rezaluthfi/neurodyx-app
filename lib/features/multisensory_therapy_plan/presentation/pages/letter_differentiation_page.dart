import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'therapy_results_page.dart';

class LetterDifferentiationPage extends StatefulWidget {
  const LetterDifferentiationPage({super.key});

  @override
  _LetterDifferentiationPageState createState() =>
      _LetterDifferentiationPageState();
}

class _LetterDifferentiationPageState extends State<LetterDifferentiationPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;

  final List<Map<String, dynamic>> questions = [
    {
      'type': 'letter_differentiation',
      'title': 'Letter Differentiation',
      'instruction': 'Drag the different letter to the box.',
      'options': ['p', 'p', 'p', 'q', 'p', 'p'],
      'correctAnswer': 'q',
      'dropCount': 1,
    },
  ];

  int get totalQuestions => questions.length;

  void selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  Future<void> showAnswerFeedbackDialog({
    required BuildContext context,
    required bool isCorrect,
    required String correctAnswer,
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
    if (selectedAnswer == null) return;

    bool isCorrect =
        selectedAnswer == questions[currentQuestionIndex]['correctAnswer'];
    if (isCorrect) {
      score++;
    }

    void nextAction() {
      setState(() {
        if (currentQuestionIndex < totalQuestions - 1) {
          currentQuestionIndex++;
          selectedAnswer = null;
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
      correctAnswer: questions[currentQuestionIndex]['correctAnswer'],
      onProceed: nextAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == totalQuestions - 1;

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
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: (currentQuestion['options'] as List<String>)
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final option = entry.value;
                            final optionId = '${option}_$index';
                            return Draggable<String>(
                              data: option,
                              child: _buildOptionButton(option, id: optionId),
                              feedback: _buildOptionButton(option),
                              childWhenDragging: Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: DragTarget<String>(
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: selectedAnswer != null
                                    ? Center(
                                        child: Text(
                                          selectedAnswer!,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                              );
                            },
                            onWillAccept: (data) => true,
                            onAccept: (data) {
                              setState(() {
                                selectedAnswer = data;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: selectedAnswer == null
                        ? Colors.grey[300]!.withOpacity(0.6)
                        : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(-2, -4),
                        blurRadius: 4,
                        color: AppColors.grey.withOpacity(0.7),
                        inset: true,
                      ),
                      if (selectedAnswer != null)
                        BoxShadow(
                          offset: const Offset(2, 4),
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.1),
                          inset: false,
                        ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed:
                        selectedAnswer == null ? null : proceedToNextQuestion,
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
                            color: selectedAnswer == null
                                ? Colors.grey[600]
                                : AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: selectedAnswer == null
                              ? Colors.grey[600]
                              : AppColors.white,
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

  Widget _buildOptionButton(String text, {String? id}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
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
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
