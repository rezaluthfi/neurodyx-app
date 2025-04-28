import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FactsAndMythsPage extends StatelessWidget {
  const FactsAndMythsPage({super.key});

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
          'Facts & Myths',
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
                "Facts & Myths About Dyslexia",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Facts Section
            const Text(
              "✅ Facts About Dyslexia",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildFact(
              "Dyslexia is not related to intelligence. Many successful people, including Albert Einstein and Steve Jobs, had dyslexia. It’s a difference in processing language, not a measure of intelligence.",
            ),
            _buildFact(
              "Early detection and support make a big difference. The sooner dyslexia is identified, the easier it is to provide effective learning strategies.",
            ),
            _buildFact(
              "Dyslexia affects people differently. Some struggle with reading, others with writing or spelling. It’s not the same for everyone.",
            ),
            _buildFact(
              "Multisensory learning can help. Engaging multiple senses—like hearing, touch, and sight—makes reading and writing easier for dyslexic learners.",
            ),
            _buildFact(
              "Dyslexia is lifelong but manageable. With the right strategies and support, individuals with dyslexia can succeed in school, work, and daily life.",
            ),
            const SizedBox(height: 16),
            // Myths Section
            const Text(
              "❌ Myths About Dyslexia",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildMyth(
              myth: "Dyslexia is just a reading problem.",
              truth:
                  "Dyslexia affects reading, spelling, writing, and even processing spoken language.",
            ),
            _buildMyth(
              myth: "Dyslexia can be outgrown.",
              truth:
                  "Dyslexia is a lifelong condition, but with the right support, individuals can learn effective coping strategies.",
            ),
            _buildMyth(
              myth: "People with dyslexia see letters backwards.",
              truth:
                  "Dyslexia is not about vision—it’s about how the brain processes language. Reversing letters is common in young learners, even those without dyslexia.",
            ),
            _buildMyth(
              myth: "Dyslexia is caused by laziness.",
              truth:
                  "Dyslexic individuals often work harder than their peers to read and write, but they process language differently.",
            ),
            _buildMyth(
              myth: "Only boys have dyslexia.",
              truth:
                  "Dyslexia affects boys and girls equally, but boys are more likely to be diagnosed due to differences in behavior.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFact(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              "✔ $text",
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

  Widget _buildMyth({required String myth, required String truth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Myth: ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary.withOpacity(0.7),
                        ),
                      ),
                      TextSpan(
                        text: myth,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textPrimary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Truth: ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary.withOpacity(0.7),
                        ),
                      ),
                      TextSpan(
                        text: truth,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textPrimary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
