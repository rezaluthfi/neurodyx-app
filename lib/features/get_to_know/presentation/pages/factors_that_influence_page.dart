import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/assets_path.dart';

class FactorsThatInfluencePage extends StatelessWidget {
  const FactorsThatInfluencePage({super.key});

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
          'Factors That Influence',
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
                "What Causes Dyslexia?",
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
                AssetPath.getToKnow2,
                height: 165,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),
            // Description
            Text(
              "Dyslexia is influenced by multiple factors, including:",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            // Genetics Section
            const Text(
              "• Genetics",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Often runs in families. If a parent has dyslexia, their child has a higher chance of having it too.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            // Neurological Differences Section
            const Text(
              "• Neurological Differences",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Brain scans show that people with dyslexia process language differently. They may have difficulty connecting sounds to letters.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            // Environmental Factors Section
            const Text(
              "• Environmental Factors",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Early language exposure and educational support can impact reading skills. A structured learning environment helps in managing dyslexia.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
