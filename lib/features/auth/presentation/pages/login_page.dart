import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:email_validator/email_validator.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';
import 'package:neurodyx/features/main/presentation/pages/main_navigator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/connectivity_service.dart';
import '../providers/auth_provider.dart';
import '../../../../core/widgets/custom_text_field.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // Clear any existing errors when the page is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).clearError();
    });

    // Add listeners to clear error when user starts typing
    _emailController.addListener(_clearErrorOnChange);
    _passwordController.addListener(_clearErrorOnChange);

    // Listen for connectivity changes using ConnectivityService
    _connectivitySubscription =
        ConnectivityService().onConnectivityChanged.listen((result) {
      if (!mounted) return;
      if (result.contains(ConnectivityResult.none)) {
        CustomSnackBar.show(
          context,
          message:
              'Network disconnected. Please check your Wi-Fi or mobile data.',
          type: SnackBarType.error,
        );
      } else if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile)) {
        CustomSnackBar.show(
          context,
          message: 'Network connected!',
          type: SnackBarType.success,
        );
      }
    });
  }

  // Clear error message when user starts typing
  void _clearErrorOnChange() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.errorMessage.isNotEmpty) {
      authProvider.clearError();
    }
  }

  @override
  void dispose() {
    // Remove listeners and dispose controllers
    _emailController.removeListener(_clearErrorOnChange);
    _passwordController.removeListener(_clearErrorOnChange);
    _emailController.dispose();
    _passwordController.dispose();
    // Cancel connectivity subscription
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Handle login process
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Check internet connection using ConnectivityService
      bool isConnected =
          await ConnectivityService().checkInternetConnection(context);
      if (!isConnected) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Show success message using CustomSnackBar
        CustomSnackBar.show(
          context,
          message: 'Login successful!',
          type: SnackBarType.success,
        );

        // Delay navigation slightly to allow the snackbar to be visible
        await Future.delayed(const Duration(seconds: 1));

        // Navigate to MainNavigator
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigator()),
            (route) => false,
          );
        }
      } else if (authProvider.errorMessage.isNotEmpty && mounted) {
        // Show error message using CustomSnackBar
        CustomSnackBar.show(
          context,
          message: authProvider.errorMessage,
          type: SnackBarType.error,
          onActionPressed: () => authProvider.clearError(),
        );
      }
    }
  }

  // Handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    // Check internet connection using ConnectivityService
    bool isConnected =
        await ConnectivityService().checkInternetConnection(context);
    if (!isConnected) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      // Show success message using CustomSnackBar
      CustomSnackBar.show(
        context,
        message: 'Login with Google successful!',
        type: SnackBarType.success,
      );

      // Delay navigation slightly to allow the snackbar to be visible
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to MainNavigator
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigator()),
          (route) => false,
        );
      }
    } else if (authProvider.errorMessage.isNotEmpty && mounted) {
      // Show error message using CustomSnackBar
      CustomSnackBar.show(
        context,
        message: authProvider.errorMessage,
        type: SnackBarType.error,
        onActionPressed: () => authProvider.clearError(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Center(
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: Image.asset(
                        AssetPath.iconLogo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email input
                  CustomTextField(
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Password input
                  CustomTextField(
                    label: 'Password',
                    hintText: 'Enter password',
                    controller: _passwordController,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: _togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Clear error before navigating
                        Provider.of<AuthProvider>(context, listen: false)
                            .clearError();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login button
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
                      onPressed: authProvider.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false)
                            .clearError();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.grey,
                                        fontSize: 14,
                                      ) ??
                                  const TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 14,
                                  ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.blue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ) ??
                                  const TextStyle(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Divider "OR"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.grey.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.grey.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Google Login Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: AppColors.white,
                      border:
                          Border.all(color: AppColors.grey.withOpacity(0.3)),
                    ),
                    child: ElevatedButton(
                      onPressed:
                          authProvider.isLoading ? null : _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AssetPath.iconGoogle,
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Login with Google',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }
}
