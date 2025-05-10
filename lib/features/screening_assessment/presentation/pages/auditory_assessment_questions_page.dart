import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import '../../../../../core/constants/app_colors.dart';

class AuditoryAssessmentQuestionsPage extends StatefulWidget {
  const AuditoryAssessmentQuestionsPage({super.key});

  @override
  _AuditoryAssessmentQuestionsPageState createState() =>
      _AuditoryAssessmentQuestionsPageState();
}

class _AuditoryAssessmentQuestionsPageState
    extends State<AuditoryAssessmentQuestionsPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer; // Track the selected answer for the current question

  final List<Map<String, dynamic>> questions = [
    // Letter Sound Guess
    {
      'type': 'letter_sound_guess',
      'title': 'Letter Sound Guess',
      'instruction':
          'Listen to the sound of the letters and choose the appropriate letter!',
      'sound': 'A', // Placeholder for the sound (e.g., letter "A")
      'options': ['b', 'p', 'd'],
      'correctAnswer': 'p',
    },

    // Word Sound Guess
    {
      'type': 'word_sound_guess',
      'title': 'Word Sound Guess',
      'instruction':
          'Listen carefully to the sound. Tap the word that matches the sound!',
      'sound': 'cat', // Placeholder for the sound (e.g., word "cat")
      'options': ['bat', 'cat', 'cap'],
      'correctAnswer': 'cat',
    },

    // Word Repetition
    {
      'type': 'word_repetition',
      'title': 'Word Repetition',
      'instruction': 'Listen and repeat the words you hear!',
      'sound': 'top top', // Placeholder for the sound (e.g., "top top")
      'options': ['top'], // Single option for speech input
      'correctAnswer': 'top',
    },
  ];

  int get totalQuestions => questions.length; // Total 9 questions

  void selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer; // Store the selected answer
    });
  }

  void proceedToNextQuestion() {
    if (selectedAnswer == null)
      return; // Prevent proceeding if no answer is selected

    // Update score if the selected answer is correct
    if (selectedAnswer == questions[currentQuestionIndex]['correctAnswer']) {
      score++;
    }

    setState(() {
      if (currentQuestionIndex < totalQuestions - 1) {
        currentQuestionIndex++;
        selectedAnswer =
            null; // Reset the selected answer for the next question
      } else {
        // Pop twice to return to DyslexiaAssessmentPage
        Navigator.pop(context, score); // Pop AuditoryAssessmentQuestionsPage
        Navigator.pop(context, score); // Pop AssessmentReadyPage
      }
    });
  }

  void playSound(String sound) {
    // Placeholder for sound playback logic
    // In a real app, use a package like audioplayers to play the sound
    print('Playing sound: $sound');
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    final questionType = currentQuestion['type'];
    final isLastQuestion = currentQuestionIndex == totalQuestions - 1;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: AppColors.offWhite,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove default back button
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
                  // Progress Indicator
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

                  // Instruction
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

                  // Sound Playback Buttons
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
                            // Placeholder for mute functionality
                            print('Mute sound');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[100],
                            foregroundColor: AppColors.textPrimary,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Icon(Icons.volume_off, size: 24),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Options
                  if (questionType == 'letter_sound_guess')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: (currentQuestion['options'] as List<String>)
                          .map((option) => SizedBox(
                                width: 80,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () => selectAnswer(option),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedAnswer == option
                                        ? AppColors.greenMint.withOpacity(0.8)
                                        : AppColors.greenMint,
                                    foregroundColor: AppColors.textPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: selectedAnswer == option
                                            ? AppColors.primary
                                            : AppColors.greenMint,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    )
                  else if (questionType == 'word_sound_guess')
                    Column(
                      children: (currentQuestion['options'] as List<String>)
                          .map((option) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => selectAnswer(option),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: selectedAnswer == option
                                          ? AppColors.greenMint.withOpacity(0.8)
                                          : AppColors.greenMint,
                                      foregroundColor: AppColors.textPrimary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: selectedAnswer == option
                                              ? AppColors.primary
                                              : AppColors.greenMint,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    )
                  else if (questionType == 'word_repetition')
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

                  // Next Button
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
