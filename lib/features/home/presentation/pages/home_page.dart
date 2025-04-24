import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Neurodyx',
          style: GoogleFonts.lexendExa(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Log Out',
                    style: GoogleFonts.lexendExa(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to log out?',
                    style: GoogleFonts.lexendExa(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.lexendExa(
                          textStyle: const TextStyle(
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await authProvider.signOut();
                        if (context.mounted) {
                          Navigator.pop(context);
                          // Navigate to login page and remove all previous routes
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                            (route) => false,
                          );
                        }
                      },
                      child: Text(
                        'Log Out',
                        style: GoogleFonts.lexendExa(
                          textStyle: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome!',
                style: GoogleFonts.lexendExa(
                  textStyle: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You are successfully logged in as:',
                style: GoogleFonts.lexendExa(
                  textStyle: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                // Prioritize username from Firestore
                user?.username != null &&
                        user!.username!.isNotEmpty &&
                        !user.username!.contains('@')
                    ? user
                        .username! // Use username if available and not an email
                    : user?.displayName ??
                        user?.email ??
                        'User', // Fallback to displayName or email
                style: GoogleFonts.lexendExa(
                  textStyle: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (user != null && !user.isEmailVerified) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade800,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please verify your email address',
                          style: GoogleFonts.lexendExa(
                            textStyle: TextStyle(
                              color: Colors.amber.shade800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Delete Account',
                        style: GoogleFonts.lexendExa(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to delete your account? This action cannot be undone.',
                        style: GoogleFonts.lexendExa(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.lexendExa(
                              textStyle: const TextStyle(
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final success = await authProvider.deleteAccount();
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                // Navigate to login page and remove all previous routes
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                  (route) => false,
                                );
                              } else {
                                // Show error message
                                if (authProvider.errorMessage.contains(
                                    'This operation requires a recent login')) {
                                  // Handle requires-recent-login error
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        'Re-login Required',
                                        style: GoogleFonts.lexendExa(
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      content: Text(
                                        'Please sign in again to delete your account.',
                                        style: GoogleFonts.lexendExa(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            await authProvider.signOut();
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginPage()),
                                                (route) => false,
                                              );
                                            }
                                          },
                                          child: Text(
                                            'Sign In',
                                            style: GoogleFonts.lexendExa(
                                              textStyle: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // Show other error messages
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        authProvider.errorMessage,
                                        style: GoogleFonts.lexendExa(),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          child: Text(
                            'Delete',
                            style: GoogleFonts.lexendExa(
                              textStyle: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Delete Account',
                  style: GoogleFonts.lexendExa(
                    textStyle: const TextStyle(
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
    );
  }
}
