import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'package:neurodyx/features/smart_screening_and_assessment/presentation/pages/screening/screening_ready_page.dart';
import '../../../../../../core/constants/app_colors.dart';

class ScreeningCategoryPage extends StatelessWidget {
  const ScreeningCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive calculations
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

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
        // Use SingleChildScrollView to prevent overflow on small screens
        child: SingleChildScrollView(
          child: Padding(
            // Adjust padding based on screen size
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '🔍',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          Text(
                            'Dyslexia Screening',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Instructions card
                Card(
                  elevation: 0,
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "About this Screening",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          "This quick screening tool helps identify potential signs of dyslexia. "
                          "The questions and evaluation criteria differ based on age group, so please "
                          "select the appropriate category below.",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Who is this screening for title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'WHO IS THIS SCREENING FOR?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Category selection cards - Use LayoutBuilder to make responsive decisions
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Determine layout based on available width
                    final bool useHorizontalLayout = constraints.maxWidth > 600;
                    // For vertical layout, calculate appropriate height
                    final double cardHeight = useHorizontalLayout
                        ? constraints.maxHeight * 0.8
                        : screenSize.height * 0.32;

                    if (useHorizontalLayout) {
                      // Horizontal layout for wider screens (tablets)
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildCategoryCard(
                              context: context,
                              category: 'kid',
                              title: 'Children',
                              subtitle: 'Ages 4-17',
                              imageAsset: AssetPath.imgKid,
                              description:
                                  'For parents or guardians to assess dyslexia signs in children',
                              height: cardHeight,
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildCategoryCard(
                              context: context,
                              category: 'adult',
                              title: 'Adults',
                              subtitle: '18+ years',
                              imageAsset: AssetPath.imgAdult,
                              description:
                                  'For adults to self-assess potential dyslexia indicators',
                              height: cardHeight,
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Vertical layout for narrower screens (phones)
                      return Column(
                        children: [
                          _buildCategoryCard(
                            context: context,
                            category: 'kid',
                            title: 'Children',
                            subtitle: 'Ages 4-17',
                            imageAsset: AssetPath.imgKid,
                            description:
                                'For parents or guardians to assess dyslexia signs in children',
                            height: cardHeight,
                            isSmallScreen: isSmallScreen,
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryCard(
                            context: context,
                            category: 'adult',
                            title: 'Adults',
                            subtitle: '18+ years',
                            imageAsset: AssetPath.imgAdult,
                            description:
                                'For adults to self-assess potential dyslexia indicators',
                            height: cardHeight,
                            isSmallScreen: isSmallScreen,
                          ),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String category,
    required String title,
    required String subtitle,
    required String imageAsset,
    required String description,
    required double height,
    required bool isSmallScreen,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    QuickScreeningReadyPage(category: category),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image container with fixed aspect ratio
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback in case image fails to load
                          return Center(
                            child: Icon(
                              category == 'kid'
                                  ? Icons.child_care
                                  : Icons.person,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Title and subtitle
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: isSmallScreen ? 3 : 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Start button
                Container(
                  width: double.infinity,
                  height: isSmallScreen ? 36 : 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.primary,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              QuickScreeningReadyPage(category: category),
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
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Start Screening',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: isSmallScreen ? 14 : 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
