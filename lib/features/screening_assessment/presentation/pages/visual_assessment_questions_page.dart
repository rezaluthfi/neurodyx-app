import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import '../../../../../core/constants/app_colors.dart';

class VisualAssessmentQuestionsPage extends StatefulWidget {
  const VisualAssessmentQuestionsPage({super.key});

  @override
  _VisualAssessmentQuestionsPageState createState() =>
      _VisualAssessmentQuestionsPageState();
}

class _VisualAssessmentQuestionsPageState
    extends State<VisualAssessmentQuestionsPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer; // Track the selected answer for the current question

  final List<Map<String, dynamic>> questions = [
    // Letter Recognition
    {
      'type': 'letter_recognition',
      'title': 'Letter Recognition',
      'instruction': 'Tap the letter that looks different from the others.',
      'question': 'd',
      'options': ['b', 'd'],
      'correctAnswer': 'd',
    },
    // Complete Word
    {
      'type': 'complete_word',
      'title': 'Complete Word',
      'instruction': 'Select the correct letter to complete the word.',
      'question': '_at',
      'image': AssetPath.imgDummyVisual1,
      'options': ['B', '8'],
      'correctAnswer': 'B',
    },
    // Word Recognition
    {
      'type': 'word_recognition',
      'title': 'Word Recognition',
      'instruction':
          'Which word is correct? Tap the word that matches the picture!',
      'question': 'apple',
      'image': AssetPath.imgDummyVisual2,
      'options': ['apqle', 'apple', 'applc', 'Apqlc'],
      'correctAnswer': 'apple',
    },
  ];

  int get totalQuestions =>
      questions.length; // Dynamically set based on list length

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
        Navigator.pop(context, score); // Pop VisualAssessmentQuestionsPage
        Navigator.pop(context, score); // Pop AssessmentReadyPage
      }
    });
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
          // Added to make content scrollable
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

                  // Question (Gambar atau Tulisan)
                  Center(
                    child: Column(
                      children: [
                        // Display image if available (for 'complete_word' and 'word_recognition')
                        if (currentQuestion['image'] != null)
                          Image.asset(
                            currentQuestion['image'],
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
                        const SizedBox(
                            height: 16), // Space between image and text
                        // Display the question text for all types
                        Text(
                          currentQuestion['question'],
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Options
                  if (questionType == 'word_recognition')
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
                                          ? AppColors.greenMint.withOpacity(
                                              0.8) // Darker shade when selected
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
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Text(
                                        option,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    )
                  else
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
                                        ? AppColors.greenMint.withOpacity(
                                            0.8) // Darker shade when selected
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
                    ),
                  const SizedBox(height: 16), // Added to ensure spacing
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
                          borderRadius: BorderRadius.circular(20),
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
