import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/multisensory_therapy_plan_page.dart';
import 'letter_differentiation_page.dart';
import 'number_letter_similarity_page.dart';
import 'letter_matching_page.dart';

class KinestheticTherapyPlanPage extends StatelessWidget {
  const KinestheticTherapyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.indigo300,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MultisensoryTherapyPlanPage(),
            ),
          ),
        ),
        title: const Text(
          'Therapy Plan',
          style: TextStyle(color: AppColors.white, fontSize: 18),
        ),
      ),
      body: Container(
        color: AppColors.indigo300,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kinesthetic Therapy Plan',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enhance your tactile and movement-based learning with these activities!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildListTile(
                      title: 'Letter Differentiation',
                      subtitle: 'Drag the different letter to the box!',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LetterDifferentiationPage(
                              category: 'letter_differentiation',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildListTile(
                      title: 'Number & Letter Similarity',
                      subtitle: 'Match each letter/number with its pair!',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NumberLetterSimilarityPage(
                              category: 'number_letter_similarity',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildListTile(
                      title: 'Letter Matching',
                      subtitle: 'Drag letters to complete the word!',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LetterMatchingPage(
                              category: 'letter_matching',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary.withOpacity(0.7),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textPrimary,
        ),
        onTap: onTap,
      ),
    );
  }
}
