import 'package:flutter/material.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/assessment/dyslexia_assessment_page.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/screening/screening_category_page.dart';

import 'package:neurodyx/features/smart_screening_and_assessment/presentation/widgets/smart_screening_and_assessment_card.dart';
import '../../../../core/constants/app_colors.dart';

class SmartScreeningAndAssessmentPage extends StatelessWidget {
  const SmartScreeningAndAssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Smart Screening & Assessment',
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmartScreeningAndAssessmentCard(
                  backgroundColor: AppColors.pink50,
                  title: 'Dyslexia Quick Screening',
                  description:
                      'Answer 10 quick questions to check for signs of dyslexia.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreeningCategoryPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SmartScreeningAndAssessmentCard(
                  backgroundColor: AppColors.blue50,
                  title: 'Dyslexia Assessment',
                  description:
                      'Identifies your strengths and needs in Visual, Auditory, Kinesthetic, and Tactile areas.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DyslexiaAssessmentPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
