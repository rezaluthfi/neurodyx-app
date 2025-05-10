import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'therapy_results_page.dart';

class WordRepetitionPage extends StatefulWidget {
  const WordRepetitionPage({super.key});

  @override
  _WordRepetitionPageState createState() => _WordRepetitionPageState();
}

class _WordRepetitionPageState extends State<WordRepetitionPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;

  final List<Map<String, dynamic>> questions = [
    {
      'type': 'word_repetition',
      'title': 'Word Repetition',
      'instruction': 'Listen and repeat the word you hear!',
      'sound': 'top', // Placeholder for the sound (e.g., "top")
      'options': ['top'], // Single option for speech input
      'correctAnswer': 'top',
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
                therapyType: 'Auditory',
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

  void playSound(String sound) {
    print('Playing sound: $sound');
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
        body: SingleChildScrollView(
          child: SafeArea(
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
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => playSound(currentQuestion['sound']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenMint,
                            foregroundColor: AppColors.textPrimary,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(24),
                          ),
                          child: const Icon(Icons.volume_up, size: 32),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            print('Mute sound');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[100],
                            foregroundColor: AppColors.textPrimary,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Icon(Icons.volume_down, size: 24),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'press to speech',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: ElevatedButton(
                            onPressed: () =>
                                selectAnswer(currentQuestion['options'][0]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedAnswer ==
                                      currentQuestion['options'][0]
                                  ? AppColors.greenMint.withOpacity(0.8)
                                  : AppColors.greenMint,
                              foregroundColor: AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: selectedAnswer ==
                                          currentQuestion['options'][0]
                                      ? AppColors.primary
                                      : AppColors.greenMint,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: const Icon(Icons.mic, size: 36),
                          ),
                        ),
                      ),
                    ],
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
      ),
    );
  }
}
