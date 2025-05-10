import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:neurodyx/features/get_to_know/presentation/pages/dyslexia_vs_delays_page.dart';
import 'package:neurodyx/features/get_to_know/presentation/pages/expert_insights_page.dart';
import 'package:neurodyx/features/get_to_know/presentation/pages/factors_that_influence_page.dart';
import 'package:neurodyx/features/get_to_know/presentation/pages/facts_and_myths_page.dart';
import 'package:neurodyx/features/get_to_know/presentation/pages/what_is_dyslexia_page.dart';
import 'package:neurodyx/features/screening_assessment/presentation/pages/screening_category_page.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

class GetToKnowPage extends StatelessWidget {
  const GetToKnowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.indigo300,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Know Dyslexia',
          style: TextStyle(color: AppColors.white, fontSize: 18),
        ),
      ),
      body: Container(
        color: AppColors.indigo300,
        child: Column(
          children: [
            // Header Section
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get to Know Dyslexia',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Learn about the early signs and how dyslexia affects learning',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content Section
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
                      context,
                      title: 'What is Dyslexia?',
                      subtitle: 'Basics of dyslexia and its impact',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WhatIsDyslexiaPage(),
                          ),
                        );
                      },
                    ),
                    _buildListTile(
                      context,
                      title: 'Factors That Influence',
                      subtitle:
                          'Genetic, neurological, and environmental aspects',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FactorsThatInfluencePage(),
                          ),
                        );
                      },
                    ),
                    _buildListTile(
                      context,
                      title: 'Expert Insights',
                      subtitle: 'Research and findings from specialists',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExpertInsightsPage(),
                          ),
                        );
                      },
                    ),
                    _buildListTile(
                      context,
                      title: 'Facts & Myths',
                      subtitle: 'Common misconceptions vs reality',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FactsAndMythsPage(),
                          ),
                        );
                      },
                    ),
                    _buildListTile(
                      context,
                      title: 'Dyslexia vs Learning Delays',
                      subtitle: 'Key differences and signs',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DyslexiaVsLearningDelaysPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Try the Test Now Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppColors.indigo300,
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
                                  const ScreeningCategoryPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          'Try the Test Now !',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required String title,
      required String subtitle,
      required VoidCallback onTap}) {
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
