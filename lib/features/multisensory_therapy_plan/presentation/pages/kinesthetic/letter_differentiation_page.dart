import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/providers/therapy_provider.dart';
import '../therapy_results_page.dart';

class LetterDifferentiationPage extends StatefulWidget {
  final String category;
  const LetterDifferentiationPage({super.key, required this.category});

  @override
  _LetterDifferentiationPageState createState() =>
      _LetterDifferentiationPageState();
}

class _LetterDifferentiationPageState extends State<LetterDifferentiationPage> {
  int currentQuestionIndex = 0;
  String? selectedAnswerId;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TherapyProvider>(context, listen: false)
          .fetchQuestions('kinesthetic', widget.category);
    });
  }

  void proceedToNextQuestion(TherapyProvider provider) {
    if (selectedAnswerId == null) return;

    final currentQuestion = provider.questions[currentQuestionIndex];
    final answer = selectedAnswerId!.split('_')[0];
    provider.addAnswer('kinesthetic', currentQuestion.id, answer);

    setState(() {
      if (currentQuestionIndex < provider.questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswerId = null;
      } else {
        isSubmitting = true;
        provider.submitAnswers('kinesthetic', widget.category).then((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TherapyResultsPage(
                therapyType: 'Kinesthetic',
                category: widget.category,
              ),
            ),
          );
        }).catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting answers: $e')),
          );
          setState(() => isSubmitting = false);
        });
      }
    });
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
                'Letter Differentiation',
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

        if (provider.questions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              title: const Text(
                'Letter Differentiation',
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

        final currentQuestion = provider.questions[currentQuestionIndex];
        final isLastQuestion =
            currentQuestionIndex == provider.questions.length - 1;

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(
                'Letter Differentiation',
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
                  final buttonSize = (constraints.maxWidth - 16 * 4) / 5;
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
                                      '${currentQuestionIndex + 1}/${provider.questions.length}',
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
                                      provider.questions.length,
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
                                      'Drag the different letter to the box.',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: (currentQuestion.options ?? [])
                                        .asMap()
                                        .entries
                                        .map((entry) {
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
                                        feedback: _buildOptionButton(
                                          option,
                                          size: buttonSize,
                                          fontSize: 24,
                                        ),
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
                                    builder:
                                        (context, candidateData, rejectedData) {
                                      return Container(
                                        width: buttonSize,
                                        height: buttonSize,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            style: BorderStyle.solid,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: selectedAnswerId != null
                                            ? Center(
                                                child: Text(
                                                  selectedAnswerId!
                                                      .split('_')[0],
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
                            color: selectedAnswerId == null || isSubmitting
                                ? Colors.grey[300]!.withOpacity(0.6)
                                : AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(-2, -4),
                                blurRadius: 4,
                                color: AppColors.grey.withOpacity(0.7),
                                inset: true,
                              ),
                              if (selectedAnswerId != null && !isSubmitting)
                                BoxShadow(
                                  offset: const Offset(2, 4),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.1),
                                  inset: false,
                                ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: selectedAnswerId != null && !isSubmitting
                                ? () => proceedToNextQuestion(provider)
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
                                    color:
                                        selectedAnswerId == null || isSubmitting
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
                                      selectedAnswerId == null || isSubmitting
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
