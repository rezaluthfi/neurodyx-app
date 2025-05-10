import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart' as local_auth;
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../../core/constants/app_colors.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _checkAuthMethod();
  }

  Future<void> _checkAuthMethod() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      bool isGoogleUser = false;
      bool hasPasswordProvider = false;

      for (final info in firebaseUser.providerData) {
        if (info.providerId == 'google.com') {
          isGoogleUser = true;
        }
        if (info.providerId == 'password') {
          hasPasswordProvider = true;
        }
      }

      if (mounted) {
        setState(() {
          _isGoogleUser = isGoogleUser && !hasPasswordProvider;
        });
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider =
          Provider.of<local_auth.AuthProvider>(context, listen: false);
      final newPassword = _newPasswordController.text.trim();
      // If the user is a Google user, we don't need to provide the old password
      final oldPassword =
          _isGoogleUser ? '' : _oldPasswordController.text.trim();

      setState(() {
        _isLoading = true;
      });

      try {
        bool success =
            await authProvider.changePassword(oldPassword, newPassword);

        if (!success &&
            authProvider.errorMessage.contains('sign in again with Google')) {
          CustomSnackBar.show(
            context,
            message: 'You need to sign in again with Google to continue',
            type: SnackBarType.error,
          );

          // Reauthenticate with Google
          success = await authProvider.reauthenticateWithGoogle();

          if (success) {
            // Change password again after reauthentication
            success = await authProvider.changePassword('', newPassword);
          }
        }

        if (context.mounted) {
          if (success) {
            CustomSnackBar.show(
              context,
              message: 'Password changed successfully',
              type: SnackBarType.success,
            );
            Navigator.pop(context);
          } else {
            CustomSnackBar.show(
              context,
              message:
                  'Failed to change password: ${authProvider.errorMessage}',
              type: SnackBarType.error,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          CustomSnackBar.show(
            context,
            message: 'Failed to change password: $e',
            type: SnackBarType.error,
          );
        }
      } finally {
        if (context.mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isGoogleUser)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Google Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'You are setting up a password for your Google account. '
                          'This will allow you to log in using your email and password '
                          'in addition to Google Sign-In.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                if (!_isGoogleUser) ...[
                  CustomTextField(
                    label: 'Current Password',
                    hintText: 'Enter your current password',
                    controller: _oldPasswordController,
                    isPassword: true,
                    obscureText: _obscureOldPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureOldPassword = !_obscureOldPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                CustomTextField(
                  label: 'New Password',
                  hintText: 'Enter new password',
                  controller: _newPasswordController,
                  isPassword: true,
                  obscureText: _obscureNewPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }
                    if (value.length < 6) {
                      return 'New password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirm New Password',
                  hintText: 'Confirm new password',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ('Please confirm your new password');
                    }
                    if (value != _newPasswordController.text) {
                      return 'New password and confirmation do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
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
                    onPressed:
                        _isLoading ? null : () => _changePassword(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save',
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
      ),
    );
  }
}
