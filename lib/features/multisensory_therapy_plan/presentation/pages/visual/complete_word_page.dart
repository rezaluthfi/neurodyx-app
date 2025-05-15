import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/therapy_results_page.dart';

import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/therapy_provider.dart';

class CompleteWordPage extends StatefulWidget {
  const CompleteWordPage({super.key});

  @override
  _CompleteWordPageState createState() => _CompleteWordPageState();
}

class _CompleteWordPageState extends State<CompleteWordPage> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isSubmitting = false;

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
                'Complete Word',
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

        if (provider.error != null) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Complete Word',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Center(
              child: Text(
                'Error: ${provider.error}',
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
          );
        }

        final questions = provider.questions
            .where((q) => q.type == 'visual' && q.category == 'complete_word')
            .toList();

        if (questions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Complete Word',
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

        final currentQuestion = questions[currentQuestionIndex];
        final isLastQuestion = currentQuestionIndex == questions.length - 1;

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(
                'Complete Word',
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
                                      '${currentQuestionIndex + 1}/${questions.length}',
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
                                      questions.length,
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
                                      'Select the correct letter to complete the word.',
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
                                                      BorderRadius.circular(12),
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
                                      await provider.submitAnswers(
                                          'visual', 'complete_word');
                                      if (mounted) {
                                        navigator.push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const TherapyResultsPage(
                                              therapyType: 'Visual',
                                              category: 'complete_word',
                                            ),
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
