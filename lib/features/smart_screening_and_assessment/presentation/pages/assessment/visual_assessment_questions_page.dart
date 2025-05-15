import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/assessment/dyslexia_assessment_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../providers/assessment_provider.dart';

class VisualAssessmentQuestionsPage extends StatefulWidget {
  const VisualAssessmentQuestionsPage({super.key});

  @override
  _VisualAssessmentQuestionsPageState createState() =>
      _VisualAssessmentQuestionsPageState();
}

class _VisualAssessmentQuestionsPageState
    extends State<VisualAssessmentQuestionsPage> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isSubmitting = false;

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
                'Visual Assessment',
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

        final visualQuestions =
            provider.questions.where((q) => q.type == 'visual').toList();

        if (visualQuestions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Visual Assessment',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: const Center(child: Text('No visual questions available')),
          );
        }

        final currentQuestion = visualQuestions[currentQuestionIndex];
        final isLastQuestion =
            currentQuestionIndex == visualQuestions.length - 1;
        final questionType = currentQuestion.category;

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                questionType == 'letter_recognition'
                    ? 'Letter Recognition'
                    : questionType == 'complete_word'
                        ? 'Complete Word'
                        : 'Word Recognition',
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
                                      '${currentQuestionIndex + 1}/${visualQuestions.length}',
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
                                      visualQuestions.length,
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
                                  questionType == 'letter_recognition'
                                      ? 'Tap the letter that looks different from the others.'
                                      : questionType == 'complete_word'
                                          ? 'Select the correct letter to complete the word.'
                                          : 'Which word is correct? Tap the word that matches the picture!',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: Column(
                                    children: [
                                      if (currentQuestion.imageURL != null)
                                        Image.network(
                                          currentQuestion.imageURL!,
                                          height: 150,
                                          width: 150,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Text(
                                              'Image not found',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: AppColors.textPrimary,
                                              ),
                                            );
                                          },
                                        ),
                                      const SizedBox(height: 16),
                                      Text(
                                        currentQuestion.content ?? '',
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
                                if (questionType == 'word_recognition')
                                  Column(
                                    children: currentQuestion.options!
                                        .map((option) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () => setState(() {
                                                    selectedAnswer = option;
                                                  }),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        selectedAnswer == option
                                                            ? AppColors
                                                                .greenMint
                                                                .withOpacity(
                                                                    0.8)
                                                            : AppColors
                                                                .greenMint,
                                                    foregroundColor:
                                                        AppColors.textPrimary,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      side: BorderSide(
                                                        color: selectedAnswer ==
                                                                option
                                                            ? AppColors.primary
                                                            : AppColors
                                                                .greenMint,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                    child: Text(
                                                      option,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: currentQuestion.options!
                                        .map((option) => SizedBox(
                                              width: 80,
                                              height: 50,
                                              child: ElevatedButton(
                                                onPressed: () => setState(() {
                                                  selectedAnswer = option;
                                                }),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      selectedAnswer == option
                                                          ? AppColors.greenMint
                                                              .withOpacity(0.8)
                                                          : AppColors.greenMint,
                                                  foregroundColor:
                                                      AppColors.textPrimary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    side: BorderSide(
                                                      color: selectedAnswer ==
                                                              option
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
                                const SizedBox(height: 16),
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
                            color: selectedAnswer == null || isSubmitting
                                ? Colors.grey[300]!.withOpacity(0.6)
                                : AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(-2, -4),
                                blurRadius: 4,
                                color: AppColors.grey.withOpacity(0.7),
                                inset: true,
                              ),
                              if (selectedAnswer != null && !isSubmitting)
                                BoxShadow(
                                  offset: const Offset(2, 4),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.1),
                                  inset: false,
                                ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: selectedAnswer == null || isSubmitting
                                ? null
                                : () async {
                                    provider.addAnswer('visual',
                                        currentQuestion.id, selectedAnswer!);
                                    if (isLastQuestion) {
                                      setState(() {
                                        isSubmitting = true;
                                      });
                                      final navigator = Navigator.of(context);
                                      await provider.submitAnswers('visual');
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
                                        selectedAnswer = null;
                                      });
                                    }
                                  },
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
                                    color:
                                        selectedAnswer == null || isSubmitting
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
                                  color: selectedAnswer == null || isSubmitting
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
}
