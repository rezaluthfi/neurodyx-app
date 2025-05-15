import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/therapy_results_page.dart';
import 'package:provider/provider.dart';
import '../../providers/therapy_provider.dart';

class WordRecognitionPage extends StatefulWidget {
  const WordRecognitionPage({super.key});

  @override
  _WordRecognitionPageState createState() => _WordRecognitionPageState();
}

class _WordRecognitionPageState extends State<WordRecognitionPage> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  void _fetchQuestions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<TherapyProvider>(context, listen: false)
            .fetchQuestions('visual', 'word_recognition');
      }
    });
  }

  void _navigateToResults() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const TherapyResultsPage(
          therapyType: 'Visual',
          category: 'word_recognition',
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _processAnswer(
      TherapyProvider provider, bool isLastQuestion) async {
    if (!mounted) return;
    provider.addAnswer(
      'visual',
      provider.questions
          .where((q) => q.type == 'visual' && q.category == 'word_recognition')
          .toList()[currentQuestionIndex]
          .id,
      selectedAnswer ?? '',
    );

    if (isLastQuestion) {
      setState(() => isSubmitting = true);
      try {
        await provider.submitAnswers('visual', 'word_recognition');
        if (mounted) _navigateToResults();
      } catch (e) {
        if (mounted) {
          setState(() => isSubmitting = false);
          CustomSnackBar.show(context,
              message: 'Error submitting answers: $e',
              type: SnackBarType.error);
        }
      }
    } else {
      if (mounted) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
        });
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
                'Word Recognition',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: const SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        }

        final questions = provider.questions
            .where(
                (q) => q.type == 'visual' && q.category == 'word_recognition')
            .toList();
        if (questions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Word Recognition',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: const SafeArea(
              child: Center(
                child: Text(
                  'No questions available',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
              ),
            ),
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
                'Word Recognition',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: isSubmitting
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : Column(
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
                                    'instruction:',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentQuestion.description ??
                                        'Which word is correct? Tap the word that matches the picture!',
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
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),
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
                                      if (isSubmitting) return;
                                      await _processAnswer(
                                          provider, isLastQuestion);
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
                                    color:
                                        selectedAnswer == null || isSubmitting
                                            ? Colors.grey[600]
                                            : AppColors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
