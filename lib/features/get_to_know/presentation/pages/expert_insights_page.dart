import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/assets_path.dart'; // Assuming you have an assets path for the images

class ExpertInsightsPage extends StatelessWidget {
  const ExpertInsightsPage({super.key});

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
          'Expert Insights',
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
            const Text(
              "What Do Experts Say?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              "Dyslexia isn’t about intelligence—it’s about how the brain processes language. With the right approach, learning can be made easier!",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            // Dyslexia ≠ Low Intelligence Section
            const Text(
              "• Dyslexia ≠ Low Intelligence",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Dyslexia does not mean low intelligence! Many brilliant minds, such as Albert Einstein, Steve Jobs, and Leonardo da Vinci, had dyslexia. With the right strategies, dyslexia is not a barrier to success.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            // Images of Famous People
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  child: Image.asset(
                    AssetPath.einsteinPhoto,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                ClipRRect(
                  child: Image.asset(
                    AssetPath.stevePhoto,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                ClipRRect(
                  child: Image.asset(
                    AssetPath.leonardoPhoto,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Early Detection is Key Section
            const Text(
              "• Early Detection is Key",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "The earlier dyslexia is identified, the better the learning outcomes. Studies show that early intervention—such as phonics training and reading therapy—helps children with dyslexia improve academically and socially.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            // Multisensory Therapy Works Section
            const Text(
              "• Multisensory Therapy Works",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Therapy methods that combine visual, auditory, and tactile elements are more effective for individuals with dyslexia.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            // Therapy Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                AssetPath.getToKnow3,
                height: 165,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            // Dyslexia Affects More Than Just Reading Section
            const Text(
              "• Dyslexia Affects More Than Just Reading",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Dyslexia is not just about reading difficulties. It can also impact language processing, organization, time management, and short-term memory. That’s why holistic support is essential.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            // Assistive Tech Can Help Section
            const Text(
              "• Assistive Tech Can Help",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tools like text-to-speech software, audiobooks, and speech recognition technology can help individuals with dyslexia in understanding information and expressing their ideas more effectively.",
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
