import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/custom_snack_bar.dart';
import '../smart_screening_and_assessment_page.dart';
import 'screening_result_page.dart';
import '../../providers/screening_provider.dart';

class QuickScreeningQuestionsPage extends StatefulWidget {
  final String category; // "kid" or "adult"

  const QuickScreeningQuestionsPage({super.key, required this.category});

  @override
  _QuickScreeningQuestionsPageState createState() =>
      _QuickScreeningQuestionsPageState();
}

class _QuickScreeningQuestionsPageState
    extends State<QuickScreeningQuestionsPage> {
  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Confirm Exit',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to exit the test?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Provider.of<ScreeningProvider>(context, listen: false).reset();
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        const SmartScreeningAndAssessmentPage(),
                  ),
                );
              },
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuestionShimmerLoading() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Shimmer.fromColors(
          baseColor: AppColors.grey.withOpacity(0.2),
          highlightColor: AppColors.grey.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder for question number and progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: constraints.maxWidth * 0.3,
                      height: 20,
                      color: AppColors.white,
                    ),
                    Container(
                      width: constraints.maxWidth * 0.15,
                      height: 16,
                      color: AppColors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Placeholder for progress bar
                Container(
                  width: double.infinity,
                  height: 10,
                  color: AppColors.white,
                ),
                const SizedBox(height: 32),
                // Placeholder for question text
                Container(
                  width: double.infinity,
                  height: constraints.maxHeight * 0.1,
                  color: AppColors.white,
                ),
                const SizedBox(height: 40),
                // Placeholder for YES/NO buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultShimmerLoading() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Shimmer.fromColors(
          baseColor: AppColors.grey.withOpacity(0.2),
          highlightColor: AppColors.grey.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Placeholder for "Your Result" title
                Container(
                  width: constraints.maxWidth * 0.4,
                  height: 18,
                  color: AppColors.white,
                ),
                const SizedBox(height: 40),
                // Placeholder for icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 40),
                // Placeholder for risk level text
                Container(
                  width: constraints.maxWidth * 0.3,
                  height: 24,
                  color: AppColors.white,
                ),
                const SizedBox(height: 16),
                // Placeholder for message text
                Column(
                  children: [
                    Container(
                      width: constraints.maxWidth * 0.9,
                      height: 16,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: constraints.maxWidth * 0.7,
                      height: 16,
                      color: AppColors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Placeholder for primary button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                const SizedBox(height: 16),
                // Placeholder for secondary button
                Container(
                  width: constraints.maxWidth * 0.3,
                  height: 16,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreeningProvider>(
      builder: (context, provider, child) {
        if (provider.isFetchingQuestions) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () async {
                  await _showExitConfirmationDialog(context);
                },
              ),
              title: const Text(
                'Quick Screening',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: _buildQuestionShimmerLoading(),
            ),
          );
        }

        if (provider.isSubmittingAnswers) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            body: SafeArea(
              child: _buildResultShimmerLoading(),
            ),
          );
        }

        if (provider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CustomSnackBar.show(
              context,
              message: provider.errorMessage!,
              type: SnackBarType.error,
            );
          });
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        provider.fetchQuestions(widget.category, context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (provider.questions.isEmpty) {
          return const Scaffold(
            backgroundColor: AppColors.offWhite,
            body: Center(
              child: Text(
                'No questions available',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }

        final currentQuestionIndex =
            provider.answers.indexWhere((answer) => answer == null);
        final questionIndex = currentQuestionIndex == -1
            ? provider.questions.length - 1
            : currentQuestionIndex;
        final totalQuestions = provider.questions.length;

        return WillPopScope(
          onWillPop: () async {
            await _showExitConfirmationDialog(context);
            return false;
          },
          child: Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () async {
                  await _showExitConfirmationDialog(context);
                },
              ),
              title: const Text(
                'Quick Screening',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'QUESTION ${questionIndex + 1}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${questionIndex + 1}/$totalQuestions',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (questionIndex + 1) / totalQuestions,
                      backgroundColor: Colors.grey[300],
                      color: AppColors.primary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: Center(
                        child: Text(
                          provider.questions[questionIndex].question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: provider.isSubmittingAnswers
                                ? null
                                : () {
                                    provider.answerQuestion(
                                        questionIndex, true);
                                    if (questionIndex == totalQuestions - 1) {
                                      provider.submitAnswers(context).then((_) {
                                        if (provider.result != null) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  QuickScreeningResultPage(
                                                      riskLevel: provider
                                                          .result!.riskLevel),
                                            ),
                                          );
                                        }
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Yes',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: provider.isSubmittingAnswers
                                ? null
                                : () {
                                    provider.answerQuestion(
                                        questionIndex, false);
                                    if (questionIndex == totalQuestions - 1) {
                                      provider.submitAnswers(context).then((_) {
                                        if (provider.result != null) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  QuickScreeningResultPage(
                                                      riskLevel: provider
                                                          .result!.riskLevel),
                                            ),
                                          );
                                        }
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'No',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
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
        );
      },
    );
  }
}
