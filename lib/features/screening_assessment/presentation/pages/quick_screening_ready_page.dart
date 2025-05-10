import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/core/widgets/custom_button.dart';
import 'package:neurodyx/features/screening_assessment/presentation/pages/quick_screening_questions_page.dart';

class QuickScreeningReadyPage extends StatelessWidget {
  final String category;

  const QuickScreeningReadyPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    String description;
    if (category == 'kid') {
      description =
          'Answer 10 quick questions to check for signs of dyslexia. Select any statements that describe you or your kid !';
    } else {
      description =
          'Answer 10 quick questions to check for signs of dyslexia. Select any statements that describe you !';
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40), // Add some top padding for balance
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40), // Space between text and question
              const Text(
                'Are you ready ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(), // Pushes buttons to the bottom
              Column(
                children: [
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuickScreeningQuestionsPage(category: category),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        textAlign: TextAlign.center,
                        'I\'m Ready',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Gap between buttons
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      text: 'Cancel',
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
