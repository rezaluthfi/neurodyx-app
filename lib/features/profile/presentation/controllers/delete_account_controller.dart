import 'package:flutter/material.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DeleteAccountController with ChangeNotifier {
  String? passwordError;
  bool isLoading = false;

  Future<bool> deleteAccount(AuthProvider authProvider, String password) async {
    isLoading = true;
    notifyListeners();

    if (password.isEmpty) {
      passwordError = 'Please enter your password';
      isLoading = false;
      notifyListeners();
      return false;
    }

    final success = await authProvider.deleteAccount(password: password);
    isLoading = false;
    passwordError = success ? null : authProvider.errorMessage;
    notifyListeners();
    return success;
  }
}
