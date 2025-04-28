import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/assets_path.dart';

class WhatIsDyslexiaPage extends StatelessWidget {
  const WhatIsDyslexiaPage({super.key});

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
          'What is Dyslexia?',
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
                "What's the Deal?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                AssetPath.getToKnow1,
                height: 165,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              "Ever feel like letters are dancing on the page? Or that reading takes way more effort than it should? You're not alone! Dyslexia is a brain-based condition that makes reading, writing, and spelling tricky—not because of intelligence, but because of how the brain processes language.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 16),

            // What It's Like Section
            Text(
              "What It’s Like:",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),

            _buildBulletPoint(
              "Reading feels like solving a puzzle every time.",
            ),
            _buildBulletPoint(
              "Spelling? More like a guessing game.",
            ),
            _buildBulletPoint(
              "Talking? Way easier than writing!",
            ),
            _buildBulletPoint(
              "Letters and words sometimes mix, flip, or just don’t make sense.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
