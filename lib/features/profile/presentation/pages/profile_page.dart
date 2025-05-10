import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/providers/font_providers.dart';
import '../../../../../core/widgets/custom_snack_bar.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../controllers/delete_account_controller.dart';
import '../widgets/editable_field.dart';
import '../widgets/edit_field_dialog.dart';
import '../widgets/profile_picture.dart';
import '../widgets/verified_status.dart';
import 'change_password_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final fontProvider = Provider.of<FontProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              ProfilePicture(
                profilePictureUrl: user?.profilePictureUrl,
                username: user?.username,
              ),
              const SizedBox(height: 24),

              // My Profile Section
              _buildSectionTitle('My Profile'),
              const SizedBox(height: 16),

              // Username Field
              EditableField(
                label: 'Username',
                value: user?.username ?? '',
                onEditTap: () => _showEditUsernameDialog(context, authProvider),
              ),
              const SizedBox(height: 16),

              // Email Field
              EditableField(
                label: 'Email',
                value: user?.email ?? '',
                isEmail: true,
                showEditIcon: false,
                suffix: VerifiedStatusBadge(
                  isVerified: user?.isEmailVerified ?? false,
                  isCompact: true,
                  onSendVerification: () async {
                    final success = await authProvider.sendEmailVerification();
                    if (success && mounted) {
                      CustomSnackBar.show(
                        context,
                        message:
                            'Verification email sent. Please check your inbox.',
                        type: SnackBarType.success,
                      );
                    } else if (authProvider.errorMessage.isNotEmpty &&
                        mounted) {
                      CustomSnackBar.show(
                        context,
                        message: authProvider.errorMessage,
                        type: SnackBarType.error,
                      );
                    }
                  },
                ),
                onEditTap: () {},
              ),
              const SizedBox(height: 16),

              // Change Password Button
              _buildActionButton(
                title: 'Change password',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordPage(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Settings Section
              _buildSectionTitle('Settings'),
              const SizedBox(height: 16),

              // Font Selection
              _buildActionButton(
                title: 'Font',
                trailing: Row(
                  children: [
                    Text(
                      fontProvider.selectedFont,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.grey,
                    ),
                  ],
                ),
                onTap: () => _showFontSelectionDialog(context, fontProvider),
              ),
              const SizedBox(height: 16),

              // Log Out Button
              _buildActionButton(
                title: 'Log out',
                textColor: AppColors.textPrimary,
                onTap: () => _showLogoutDialog(context, authProvider),
              ),
              const SizedBox(height: 16),

              // Delete Account Button
              _buildActionButton(
                title: 'Delete Account',
                textColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(context, authProvider),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required VoidCallback onTap,
    Color textColor = AppColors.textPrimary,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            trailing ??
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.grey,
                ),
          ],
        ),
      ),
    );
  }

  void _showEditUsernameDialog(
      BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => EditFieldDialog(
        title: 'Edit Username',
        initialValue: authProvider.user?.username ?? '',
        validator: authProvider.validateUsername,
        onSave: (newValue) async {
          final success = await authProvider.updateUsername(newValue);
          if (success && mounted) {
            CustomSnackBar.show(
              context,
              message: 'Username updated successfully!',
              type: SnackBarType.success,
            );
            return true;
          } else if (authProvider.errorMessage.isNotEmpty && mounted) {
            CustomSnackBar.show(
              context,
              message: authProvider.errorMessage,
              type: SnackBarType.error,
            );
            return false;
          }
          return false;
        },
      ),
    );
  }

  void _showFontSelectionDialog(
      BuildContext context, FontProvider fontProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Font',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              RadioListTile<String>(
                value: 'Lexend Exa',
                groupValue: fontProvider.selectedFont,
                onChanged: (value) {
                  fontProvider.setFont(value!);
                  Navigator.pop(context);
                },
                title: const Text(
                  'Lexend Exa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                activeColor: AppColors.blue,
              ),
              RadioListTile<String>(
                value: 'Open Dyslexic Mono',
                groupValue: fontProvider.selectedFont,
                onChanged: (value) {
                  fontProvider.setFont(value!);
                  Navigator.pop(context);
                },
                title: const Text(
                  'Open Dyslexic Mono',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                activeColor: AppColors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Are you sure you want to log out?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: const Text(
                      'Log out',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(
      BuildContext context, AuthProvider authProvider) async {
    final isGoogleUser = await authProvider.isGoogleUser();
    if (isGoogleUser) {
      _showGoogleDeleteAccountDialog(context, authProvider);
    } else {
      _showNonGoogleDeleteAccountDialog(context, authProvider);
    }
  }

  void _showGoogleDeleteAccountDialog(
      BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to delete your account? This action cannot be undone.',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final success = await authProvider.deleteAccount();
                      if (success && dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        if (context.mounted) {
                          CustomSnackBar.show(
                            context,
                            message: 'Account deleted successfully!',
                            type: SnackBarType.success,
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      } else if (authProvider.errorMessage.isNotEmpty &&
                          dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        if (context.mounted) {
                          CustomSnackBar.show(
                            context,
                            message: authProvider.errorMessage,
                            type: SnackBarType.error,
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNonGoogleDeleteAccountDialog(
      BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider(
        create: (_) => DeleteAccountController(),
        child: Consumer<DeleteAccountController>(
          builder: (context, controller, _) {
            final passwordController = TextEditingController();
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please enter your password to confirm account deletion. This action cannot be undone.',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        errorText: controller.passwordError,
                      ),
                      enabled: !controller.isLoading,
                      onChanged: (_) => controller.passwordError = null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: controller.isLoading
                              ? null
                              : () => Navigator.pop(dialogContext),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  final password = passwordController.text;
                                  final success = await controller
                                      .deleteAccount(authProvider, password);
                                  if (success && dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                    if (context.mounted) {
                                      CustomSnackBar.show(
                                        context,
                                        message:
                                            'Account deleted successfully!',
                                        type: SnackBarType.success,
                                      );
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                          child: controller.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
