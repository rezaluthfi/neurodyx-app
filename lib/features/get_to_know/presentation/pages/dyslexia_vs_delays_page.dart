import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DyslexiaVsLearningDelaysPage extends StatelessWidget {
  const DyslexiaVsLearningDelaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Dyslexia vs Learning Delays',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Center(
              child: Text(
                "How Is Dyslexia Different?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Description
            Text(
              "Dyslexia is often confused with general learning delays, but it has distinct characteristics that set it apart. Here’s how dyslexia differs from other learning challenges:",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            // Section 1: Dyslexia vs. Learning Delays
            const Text(
              "1. Dyslexia vs. Learning Delays",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildComparison(
              title: "Dyslexia:",
              description:
                  "Affects reading, spelling, and language processing, despite normal intelligence.",
            ),
            _buildComparison(
              title: "General Learning Delays:",
              description:
                  "Slower development across multiple subjects, often due to cognitive delays.",
            ),
            const SizedBox(height: 16),
            // Section 2: Dyslexia vs. Attention Deficit Disorders (ADHD)
            const Text(
              "2. Dyslexia vs. Attention Deficit Disorders (ADHD)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildComparison(
              title: "Dyslexia:",
              description:
                  "Difficulty recognizing words, slow reading, and trouble with spelling.",
            ),
            _buildComparison(
              title: "ADHD:",
              description:
                  "Trouble focusing, impulsivity, and forgetfulness, but not necessarily struggles with language processing.",
            ),
            const SizedBox(height: 16),
            // Section 3: Dyslexia vs. Vision Problems
            const Text(
              "3. Dyslexia vs. Vision Problems",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildComparison(
              title: "Dyslexia:",
              description:
                  "A neurological difference in language processing, not an issue with eyesight.",
            ),
            _buildComparison(
              title: "Vision Issues:",
              description:
                  "Blurry text, double vision, or difficulty tracking words due to eye conditions.",
            ),
            const SizedBox(height: 16),
            // Section 4: Dyslexia vs. Speech Delays
            const Text(
              "4. Dyslexia vs. Speech Delays",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildComparison(
              title: "Dyslexia:",
              description:
                  "Struggles with reading and writing but can have strong verbal skills.",
            ),
            _buildComparison(
              title: "Speech Delay:",
              description:
                  "Difficulty forming words or sentences due to delayed language development.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparison(
      {required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
