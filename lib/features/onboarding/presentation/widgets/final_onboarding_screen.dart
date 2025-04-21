import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import '../../../../core/constants/app_colors.dart';

class FinalOnboardingScreen extends StatelessWidget {
  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;

  const FinalOnboardingScreen({
    super.key,
    required this.onCreateAccount,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (turtle)
            SizedBox(
              height: 120,
              width: 120,
              child: Image.asset(
                'assets/images/logo/icon_logo.png',
                fit: BoxFit.contain,
              ),
            ),

            // NEURODYX text
            Text(
              'NEURODYX',
              style: GoogleFonts.lexendExa(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Tagline text
            Text(
              'Commit to your therapy\nand watch your progress\ntake shape!',
              style: GoogleFonts.lexendExa(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.4,
                  decoration: TextDecoration.none,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),

            // Create account button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: AppColors.yellow,
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
                onPressed: onCreateAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: onLogin,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'I ALREADY HAVE AN ACCOUNT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
