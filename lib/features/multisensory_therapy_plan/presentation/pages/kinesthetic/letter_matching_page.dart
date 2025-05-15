import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/providers/therapy_provider.dart';
import '../therapy_results_page.dart';

class LetterMatchingPage extends StatefulWidget {
  final String category;
  const LetterMatchingPage({super.key, required this.category});

  @override
  _LetterMatchingPageState createState() => _LetterMatchingPageState();
}

class _LetterMatchingPageState extends State<LetterMatchingPage> {
  int currentQuestionIndex = 0;
  List<String> droppedAnswers = [];
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
            .fetchQuestions('kinesthetic', widget.category);
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToResultsPage() {
    if (!mounted) return;

    // Use pushAndRemoveUntil to clear navigation stack and avoid state issues
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => TherapyResultsPage(
          therapyType: 'Kinesthetic',
          category: widget.category,
        ),
      ),
      (route) => false, // Remove all previous routes
    );
  }

  Future<void> _handleSubmit(TherapyProvider provider, dynamic currentQuestion,
      bool isLastQuestion) async {
    try {
      if (!mounted) return;

      // Add current answer
      provider.addAnswer(
        'kinesthetic',
        currentQuestion.id,
        droppedAnswers.join(','),
      );

      // If not last question, just move to next question
      if (!isLastQuestion) {
        setState(() {
          currentQuestionIndex++;
          droppedAnswers = [];
        });
        return;
      }

      // For last question, show loading and submit
      setState(() {
        isSubmitting = true;
      });

      // Submit answers
      await provider.submitAnswers('kinesthetic', widget.category);

      // Navigate to results page if still mounted
      if (mounted) {
        _navigateToResultsPage();
      }
    } catch (e, stackTrace) {
      debugPrint('Submission error: $e\n$stackTrace');

      // Reset loading state if still mounted
      if (mounted) {
        setState(() => isSubmitting = false);
        _showErrorSnackBar('Error submitting answers: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Letter Matching',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<TherapyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingUI();
          }

          if (provider.questions.isEmpty) {
            return const Center(child: Text('No questions available'));
          }

          final currentQuestion = provider.questions[currentQuestionIndex];
          final isLastQuestion =
              currentQuestionIndex == provider.questions.length - 1;
          final dropCount = _getDropCount(currentQuestion);
          bool canProceed = droppedAnswers.length == dropCount;

          return WillPopScope(
            onWillPop: () async => false,
            child: SafeArea(
              child: _buildContentUI(
                provider: provider,
                currentQuestion: currentQuestion,
                isLastQuestion: isLastQuestion,
                dropCount: dropCount,
                canProceed: canProceed,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingUI() {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: AppColors.grey.withOpacity(0.2),
        highlightColor: AppColors.grey.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
    );
  }

  Widget _buildContentUI({
    required TherapyProvider provider,
    required dynamic currentQuestion,
    required bool isLastQuestion,
    required int dropCount,
    required bool canProceed,
  }) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionHeader(provider),
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
                        'Drag the correct letters into the boxes to complete the word.',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildQuestionContent(currentQuestion, dropCount),
                ],
              ),
            ),
          ),
        ),
        _buildActionButton(
          isLastQuestion: isLastQuestion,
          canProceed: canProceed,
          onPressed: canProceed && !isSubmitting
              ? () => _handleSubmit(provider, currentQuestion, isLastQuestion)
              : null,
        ),
      ],
    );
  }

  Widget _buildQuestionHeader(TherapyProvider provider) {
    return Column(
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
          value: (currentQuestionIndex + 1) / provider.questions.length,
          backgroundColor: Colors.grey[300],
          color: AppColors.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required bool isLastQuestion,
    required bool canProceed,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: onPressed == null
              ? Colors.grey[300]!.withOpacity(0.6)
              : AppColors.primary,
          boxShadow: [
            BoxShadow(
              offset: const Offset(-2, -4),
              blurRadius: 4,
              color: AppColors.grey.withOpacity(0.7),
              inset: true,
            ),
            if (onPressed != null)
              BoxShadow(
                offset: const Offset(2, 4),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.1),
                inset: false,
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
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
                  color: onPressed == null ? Colors.grey[600] : AppColors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isLastQuestion ? Icons.check : Icons.arrow_forward,
                size: 20,
                color: onPressed == null ? Colors.grey[600] : AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getDropCount(dynamic currentQuestion) {
    if (currentQuestion.correctSequence != null &&
        currentQuestion.correctSequence.isNotEmpty) {
      return currentQuestion.correctSequence.length;
    }

    final correctAnswer = currentQuestion.correctAnswer as String?;
    if (correctAnswer == null || correctAnswer.isEmpty) {
      debugPrint(
          'Warning: Both correctSequence and correctAnswer are null or empty for question ID: ${currentQuestion.id}');
      return 0;
    }
    final parts = correctAnswer.split(',');
    if (parts.isEmpty || parts.every((p) => p.trim().isEmpty)) {
      debugPrint(
          'Warning: correctAnswer "$correctAnswer" splits into empty parts for question ID: ${currentQuestion.id}');
      return 0;
    }
    return parts.length;
  }

  Widget _buildQuestionContent(dynamic currentQuestion, int dropCount) {
    final List<String> options = _parseOptions(currentQuestion.options);
    if (options.isEmpty) {
      debugPrint(
          'Warning: No options available for question ID: ${currentQuestion.id}');
    }

    if (dropCount == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No drop targets available.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
            TextButton(
              onPressed: _fetchQuestions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (currentQuestion.imageURL != null)
            Center(
              child: Image.network(
                currentQuestion.imageURL!,
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
            ),
          const SizedBox(height: 16),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                dropCount,
                (index) => DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? AppColors.primary
                              : Colors.grey,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: index < droppedAnswers.length
                          ? Center(
                              child: Text(
                                droppedAnswers[index],
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
                      if (index < droppedAnswers.length) {
                        droppedAnswers[index] = data.data;
                      } else {
                        droppedAnswers.add(data.data);
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final optionId = '${option}_$index';
                if (droppedAnswers.contains(option)) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                  );
                }
                return Draggable<String>(
                  data: option,
                  feedback: _buildOptionButton(option, size: 60, fontSize: 24),
                  childWhenDragging: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                  ),
                  child: _buildOptionButton(
                    option,
                    id: optionId,
                    size: 60,
                    fontSize: 24,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<String> _parseOptions(dynamic options) {
    if (options == null) {
      return [];
    }

    if (options is List) {
      return options.map((option) => option.toString()).toList();
    } else if (options is String) {
      return options.split(',').map((e) => e.trim()).toList();
    }

    return [];
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
