import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final authStatus = authProvider.status;

    switch (authStatus) {
      case AuthStatus.initial:
        // Show loading while auth state is being determined
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.authenticated:
        // Navigate to home page if authenticated
        return const HomePage();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      default:
        // Show onboarding if not authenticated
        return const OnboardingPage();
    }
  }
}
