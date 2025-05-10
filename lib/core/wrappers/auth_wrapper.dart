import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/main/presentation/pages/main_navigator.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Trigger checkAuthStatus when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final authStatus = authProvider.status;

    // Handle post-authentication actions (e.g., after logout or account deletion)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authStatus == AuthStatus.unauthenticated &&
          authProvider.isPostAuthAction &&
          context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    });

    switch (authStatus) {
      case AuthStatus.initial:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.authenticated:
        return const MainNavigator();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        if (authProvider.isPostAuthAction) {
          return const LoginPage();
        }
        return const OnboardingPage();
      default:
        return const OnboardingPage();
    }
  }
}
