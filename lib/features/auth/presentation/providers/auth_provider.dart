import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error
}

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  String _errorMessage = '';
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      _user = user;
      _status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  // Sign in
  Future<bool> signIn(String email, String password) async {
    try {
      clearError();
      _setLoading(true);
      _status = AuthStatus.authenticating;
      notifyListeners();
      await _authRepository.signIn(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setAuthError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Register
  Future<bool> register(String email, String password, String username) async {
    try {
      clearError();
      _setLoading(true);
      _status = AuthStatus.authenticating;
      notifyListeners();
      await _authRepository.register(email, password, username);
      _setLoading(false);
      return true;
    } catch (e) {
      _setAuthError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      clearError();
      _setLoading(true);
      _status = AuthStatus.authenticating;
      notifyListeners();
      await _authRepository.signInWithGoogle();
      _setLoading(false);
      return true;
    } catch (e) {
      _setAuthError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      clearError();
      _setLoading(true);
      await _authRepository.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setAuthError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      clearError();
      _setLoading(true);
      _status = AuthStatus.authenticating;
      notifyListeners();
      await _authRepository.deleteAccount();
      _setLoading(false);
      return true;
    } catch (e) {
      _setAuthError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message and status
  void _setAuthError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
