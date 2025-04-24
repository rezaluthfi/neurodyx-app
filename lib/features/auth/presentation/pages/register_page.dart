import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:email_validator/email_validator.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_input_field.dart';
import 'login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _usernameController.addListener(_clearErrorOnChange);
    _passwordController.addListener(_clearErrorOnChange);
    _confirmPasswordController.addListener(_clearErrorOnChange);

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

  void _clearErrorOnChange() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.errorMessage.isNotEmpty) {
      authProvider.clearError();
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearErrorOnChange);
    _usernameController.removeListener(_clearErrorOnChange);
    _passwordController.removeListener(_clearErrorOnChange);
    _confirmPasswordController.removeListener(_clearErrorOnChange);
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    // Cancel connectivity subscription
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Check internet connection using ConnectivityService
      bool isConnected =
          await ConnectivityService().checkInternetConnection(context);
      if (!isConnected) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
      );

      if (success && mounted) {
        // Show success message using CustomSnackBar
        CustomSnackBar.show(
          context,
          message: 'Registration successful! Please verify your email.',
          type: SnackBarType.success,
        );

        // Delay navigation slightly to allow the snackbar to be visible
        await Future.delayed(const Duration(seconds: 1));

        // Go back to login page
        if (mounted) {
          Navigator.of(context).pop();
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

  Future<void> _registerWithGoogle() async {
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
        message: 'Registration with Google successful!',
        type: SnackBarType.success,
      );

      // Delay navigation slightly to allow the snackbar to be visible
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to HomePage and remove all previous routes
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
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
            padding: const EdgeInsets.all(32.0),
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
                  Center(
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.lexendExa(
                        textStyle: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Username input
                  AuthInputField(
                    label: 'Username',
                    hintText: 'Enter your username',
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      if (value.contains(' ')) {
                        return 'Username cannot contain spaces';
                      }
                      // Regular expression to check if username contains only letters, numbers, dots, and underscores
                      final validCharacters = RegExp(r'^[a-zA-Z0-9._]+$');
                      if (!validCharacters.hasMatch(value)) {
                        return 'Username can only contain letters, numbers, dots, and underscores';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Email input
                  AuthInputField(
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
                  AuthInputField(
                    label: 'Password',
                    hintText: 'Enter password',
                    controller: _passwordController,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: _togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Confirm Password input
                  AuthInputField(
                    label: 'Confirm Password',
                    hintText: 'Confirm password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: _toggleConfirmPasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Register button
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
                      onPressed: authProvider.isLoading ? null : _register,
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
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Clear error before navigating
                        Provider.of<AuthProvider>(context, listen: false)
                            .clearError();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: GoogleFonts.lexendExa(
                            textStyle: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                            ),
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: GoogleFonts.lexendExa(
                                textStyle: const TextStyle(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: GoogleFonts.lexendExa(
                            textStyle: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
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

                  // Register with Google Button
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
                          authProvider.isLoading ? null : _registerWithGoogle,
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
                          Text(
                            'Register with Google',
                            style: GoogleFonts.lexendExa(
                              textStyle: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
