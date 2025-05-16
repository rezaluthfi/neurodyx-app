import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/home/presentation/pages/home_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/tactile/complete_word_by_touch_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/multisensory_therapy_plan_page.dart';
import 'package:neurodyx/features/multisensory_therapy_plan/presentation/pages/tactile/word_recognition_by_touch_page.dart';

class TactileTherapyPlanPage extends StatelessWidget {
  const TactileTherapyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.indigo300,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MultisensoryTherapyPlanPage(),
              ),
            );
          },
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
                    'Tactile Therapy Plan',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Improve your touch-based learning with these activities!',
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
                      title: 'Word Recognition by Touch',
                      subtitle: 'Draw the letter to recognize it!',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const WordRecognitionByTouchPage(
                              category: 'word_recognition_by_touch',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildListTile(
                      title: 'Complete the Word by Touch',
                      subtitle: 'Draw the missing letter to complete the word!',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CompleteWordByTouch(
                              category: 'complete_the_word_by_touch',
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
