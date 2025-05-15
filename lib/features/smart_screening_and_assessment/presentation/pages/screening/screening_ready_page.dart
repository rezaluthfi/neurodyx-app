import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/screening/screening_questions_page.dart';
import 'package:provider/provider.dart';
import '../../providers/screening_provider.dart';
import 'package:shimmer/shimmer.dart';

class QuickScreeningReadyPage extends StatefulWidget {
  final String category;

  const QuickScreeningReadyPage({super.key, required this.category});

  @override
  _QuickScreeningReadyPageState createState() =>
      _QuickScreeningReadyPageState();
}

class _QuickScreeningReadyPageState extends State<QuickScreeningReadyPage> {
  bool _isNavigating = false;

  Widget _buildShimmerLoading() {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreeningProvider>(
      builder: (context, provider, child) {
        if (_isNavigating && provider.isFetchingQuestions) {
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              backgroundColor: AppColors.offWhite,
              elevation: 0,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () {
                  setState(() {
                    _isNavigating = false;
                  });
                  provider.reset();
                },
              ),
              title: const Text(
                'Quick Screening',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: _buildShimmerLoading(),
            ),
          );
        }

        String description;
        String welcomeText;
        String instructionText;

        if (widget.category == 'kid') {
          description = 'Dyslexia Screening for Children';
          welcomeText = 'Welcome to';
          instructionText =
              'Answer 10 quick questions to check for signs of dyslexia in your child. This screening helps identify potential learning differences that may benefit from further assessment.';
        } else {
          description = 'Dyslexia Screening for Adults';
          welcomeText = 'Welcome to';
          instructionText =
              'Answer 10 quick questions to check for signs of dyslexia. This screening helps identify potential learning differences that may benefit from further assessment.';
        }

        return Scaffold(
          backgroundColor: AppColors.offWhite,
          appBar: AppBar(
            backgroundColor: AppColors.offWhite,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Quick Screening',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // Header with icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '🔍',
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      welcomeText,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      description,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Instructions card
                          Card(
                            elevation: 0,
                            color: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Instructions",
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    instructionText,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // What to expect card
                          Card(
                            elevation: 0,
                            color: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "What to Expect",
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "During this quick screening, you will:",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...[
                                    "Answer 10 simple yes/no questions",
                                    "Complete the screening in about 2-3 minutes",
                                    "Get a preliminary assessment of potential dyslexia indicators",
                                    "Receive guidance on next steps based on your results"
                                  ].map((item) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "•  ",
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        // Start button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(-2, -4),
                                blurRadius: 4,
                                color: AppColors.grey.withOpacity(0.7),
                                inset: true,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isNavigating = true;
                              });
                              await provider.fetchQuestions(
                                  widget.category, context);
                              if (provider.errorMessage == null &&
                                  _isNavigating) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        QuickScreeningQuestionsPage(
                                      category: widget.category,
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _isNavigating = false;
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
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start Screening',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Cancel button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Cancel',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
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
