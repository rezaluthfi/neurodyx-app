import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'visual/visual_therapy_plan_page.dart';
import 'auditory/auditory_therapy_plan_page.dart';
import 'kinesthetic/kinesthetic_therapy_plan_page.dart';
import 'tactile/tactile_therapy_plan_page.dart';

class MultisensoryTherapyPlanPage extends StatelessWidget {
  const MultisensoryTherapyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen size to make responsive decisions
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLandscape = screenSize.width > screenSize.height;

    // Adjust font sizes based on screen width
    final double titleFontSize = screenSize.width < 360 ? 16.0 : 18.0;
    final double headerFontSize = screenSize.width < 360 ? 14.0 : 16.0;
    final double cardTitleFontSize = screenSize.width < 360 ? 12.0 : 14.0;
    final double iconSize = screenSize.width < 360 ? 32.0 : 40.0;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            // Navigate to MainNavigator with HomePage tab
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false, // Clear stack to make MainNavigator the root
            );
          },
        ),
        title: Text(
          'Multisensory Therapy Plan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHOOSE A MULTISENSORY APPROACH THAT FITS YOUR NEEDS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Responsive layout based on orientation
                  isLandscape
                      ? _buildLandscapeLayout(
                          context: context,
                          cardTitleFontSize: cardTitleFontSize,
                          iconSize: iconSize,
                        )
                      : _buildPortraitLayout(
                          context: context,
                          cardTitleFontSize: cardTitleFontSize,
                          iconSize: iconSize,
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Portrait layout (vertical screens)
  Widget _buildPortraitLayout({
    required BuildContext context,
    required double cardTitleFontSize,
    required double iconSize,
  }) {
    return Column(
      children: [
        // First Row: Visual and Auditory
        Row(
          children: [
            // Visual Card
            Expanded(
              child: _buildTherapyCard(
                context: context,
                title: 'VISUAL',
                icon: '👁️',
                onTap: () =>
                    _navigateToPage(context, const VisualTherapyPlanPage()),
                titleFontSize: cardTitleFontSize,
                iconSize: iconSize,
              ),
            ),
            const SizedBox(width: 16),
            // Auditory Card
            Expanded(
              child: _buildTherapyCard(
                context: context,
                title: 'AUDITORY',
                icon: '📢',
                onTap: () =>
                    _navigateToPage(context, const AuditoryTherapyPlanPage()),
                titleFontSize: cardTitleFontSize,
                iconSize: iconSize,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second Row: Kinesthetic and Tactile
        Row(
          children: [
            // Kinesthetic Card
            Expanded(
              child: _buildTherapyCard(
                context: context,
                title: 'KINESTHETIC',
                icon: '✋',
                onTap: () => _navigateToPage(
                    context, const KinestheticTherapyPlanPage()),
                titleFontSize: cardTitleFontSize,
                iconSize: iconSize,
              ),
            ),
            const SizedBox(width: 16),
            // Tactile Card
            Expanded(
              child: _buildTherapyCard(
                context: context,
                title: 'TACTILE',
                icon: '🎶',
                onTap: () =>
                    _navigateToPage(context, const TactileTherapyPlanPage()),
                titleFontSize: cardTitleFontSize,
                iconSize: iconSize,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Landscape layout (horizontal screens)
  Widget _buildLandscapeLayout({
    required BuildContext context,
    required double cardTitleFontSize,
    required double iconSize,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Visual and Auditory
        Expanded(
          child: Column(
            children: [
              // Visual Card
              _buildTherapyCard(
                context: context,
                title: 'VISUAL',
                icon: '👁️',
                onTap: () =>
                    _navigateToPage(context, const VisualTherapyPlanPage()),
                titleFontSize: cardTitleFontSize,
                iconSize: iconSize,
              ),
              const SizedBox(height: 16),
              // Auditory Card
              _buildTherapyCard(
                context: context,
                title: 'AUDITORY',
                icon: '📢',
                onTap: () =>
                    _navigateToPage(context, const AuditoryTherapyPlanPage()),
                titleFontSize: cardTitleFontSize,
                iconSize: iconSize,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right Column: Kinesthetic and Tactile
        Expanded(
          child: Column(
            children: [
              // Kinesthetic Card
              _buildTherapyCard(
                context: context,
                title: 'KINESTHETIC',
                icon: '✋',
                onTap: () => _navigateToPage(
                    context, const KinestheticTherapyPlanPage()),
                titleFontSize: cardTitleFontSize,
                iconSize: iconSize,
              ),
              const SizedBox(height: 16),
              // Tactile Card
              _buildTherapyCard(
                context: context,
                title: 'TACTILE',
                icon: '🎶',
                onTap: () =>
                    _navigateToPage(context, const TactileTherapyPlanPage()),
                titleFontSize: cardTitleFontSize,
                iconSize: iconSize,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Navigation helper method
  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildTherapyCard({
    required BuildContext context,
    required String title,
    required String icon,
    required VoidCallback onTap,
    required double titleFontSize,
    required double iconSize,
  }) {
    // Use an aspect ratio to ensure card maintains a good shape
    return AspectRatio(
      aspectRatio: 1.2,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  icon,
                  style: TextStyle(fontSize: iconSize),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
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
