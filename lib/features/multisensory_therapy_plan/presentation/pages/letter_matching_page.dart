import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'therapy_results_page.dart';

class LetterMatchingPage extends StatefulWidget {
  const LetterMatchingPage({super.key});

  @override
  _LetterMatchingPageState createState() => _LetterMatchingPageState();
}

class _LetterMatchingPageState extends State<LetterMatchingPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  List<String> droppedAnswers = [];

  final List<Map<String, dynamic>> questions = [
    {
      'type': 'letter_matching',
      'title': 'Letter Matching',
      'instruction':
          'Drag the correct letters into the boxes to complete the word.',
      'question': 'dog',
      'image': AssetPath.imgDummyKinesthetic1,
      'options': ['b', 'd', 'o', 'a', 'g'],
      'correctAnswer': ['d', 'o', 'g'],
      'dropCount': 3,
    },
  ];

  int get totalQuestions => questions.length;

  bool listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
    bool isCorrect =
        listEquals(droppedAnswers, currentQuestion['correctAnswer']);

    if (isCorrect) {
      score++;
    }

    void nextAction() {
      setState(() {
        if (currentQuestionIndex < totalQuestions - 1) {
          currentQuestionIndex++;
          droppedAnswers = [];
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

    bool canProceed = droppedAnswers.length == currentQuestion['dropCount'];

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
                        if (currentQuestion['image'] != null)
                          Image.asset(
                            currentQuestion['image'],
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                width: 150,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Text(
                                    'Failed to load image: $error',
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: (currentQuestion['question'] as String)
                              .split('')
                              .map((char) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      char,
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: List.generate(
                            (currentQuestion['dropCount'] as int),
                            (index) => DragTarget<String>(
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
                                  child: droppedAnswers.length > index
                                      ? Center(
                                          child: Text(
                                            droppedAnswers[index],
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
                                  if (droppedAnswers.length <= index) {
                                    while (droppedAnswers.length < index) {
                                      droppedAnswers.add('');
                                    }
                                    droppedAnswers.add(data);
                                  } else {
                                    droppedAnswers[index] = data;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: (currentQuestion['options'] as List<String>)
                              .map((option) => Draggable<String>(
                                    data: option,
                                    child: _buildOptionButton(option),
                                    feedback: _buildOptionButton(option),
                                    childWhenDragging: Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[200],
                                    ),
                                  ))
                              .toList(),
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

  Widget _buildOptionButton(String text) {
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
