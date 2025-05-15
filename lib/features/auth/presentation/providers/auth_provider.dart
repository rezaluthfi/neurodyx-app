import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isPostAuthAction = false;
  Timer? _emailVerificationTimer;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isPostAuthAction => _isPostAuthAction;

  AuthProvider() {
    _authRepository.authStateChanges.listen((user) {
      _user = user;
      _status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();

      if (user != null && !user.isEmailVerified) {
        _startEmailVerificationPolling();
      } else {
        _stopEmailVerificationPolling();
      }
    });
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _authRepository.currentUser;
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (await _authRepository.isTokenValid()) {
        _status = AuthStatus.authenticated;
        _user = user;
      } else if (await _authRepository.isRefreshTokenValid()) {
        await _authRepository.refreshAuthToken();
        _status = AuthStatus.authenticated;
        _user = user;
      } else {
        await _authRepository.signOut();
        _status = AuthStatus.unauthenticated;
        _user = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setAuthError('Failed to check auth status: $e');
      _status = AuthStatus.error;
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startEmailVerificationPolling() {
    _stopEmailVerificationPolling();
    _emailVerificationTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _refreshUser();
    });
  }

  void _stopEmailVerificationPolling() {
    _emailVerificationTimer?.cancel();
    _emailVerificationTimer = null;
  }

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

  Future<bool> isGoogleUser() async {
    try {
      final currentUser = await _authRepository.currentUser;
      if (currentUser != null) {
        return await _authRepository.isUserFromGoogle();
      }
      return false;
    } catch (e) {
      _setAuthError(e.toString());
      return false;
    }
  }

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

  Future<bool> reauthenticateWithGoogle() async {
    try {
      print('Attempting Google reauthentication...');
      await _authRepository.reauthenticateWithGoogle();
      print('Google reauthentication successful');
      return true;
    } catch (e) {
      _setAuthError('Google reauthentication failed: $e');
      print('Google reauthentication error: $e');
      return false;
    }
  }

  Future<bool> reauthenticateWithEmailPassword(String password) async {
    try {
      print('Attempting email/password reauthentication...');
      await _authRepository.reauthenticateWithEmailPassword(password);
      print('Email/password reauthentication successful');
      return true;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('wrong-password')) {
        errorMessage = 'The password you entered is incorrect.';
      } else if (errorMessage.contains('operation-not-allowed')) {
        errorMessage = 'Authentication is not enabled. Contact support.';
      }
      _setAuthError(errorMessage);
      print('Email/password reauthentication error: $errorMessage');
      return false;
    }
  }

  Future<void> signOut() async {
    _isPostAuthAction = true;
    await _authRepository.signOut();
    _stopEmailVerificationPolling();
    notifyListeners();
  }

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

  Future<bool> deleteAccount({String? password}) async {
    try {
      clearError();
      _setLoading(true);
      print('Starting account deletion...');

      await _authRepository.deleteAccount(password: password);
      await _authRepository.signOut();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _isPostAuthAction = true;
      _setLoading(false);
      _stopEmailVerificationPolling();
      print(
          'Account deleted, status: $_status, isPostAuthAction: $_isPostAuthAction');
      notifyListeners();

      return true;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('wrong-password')) {
        errorMessage = 'The password you entered is incorrect.';
      } else if (errorMessage.contains('no-user-signed-in')) {
        errorMessage = 'No user is currently signed in.';
      } else if (errorMessage.contains('no-supported-provider')) {
        errorMessage = 'Account deletion is not supported for this provider.';
      } else if (errorMessage.contains('password-required')) {
        errorMessage =
            'Password is required for email/password account deletion.';
      } else if (errorMessage.contains('operation-not-allowed')) {
        errorMessage = 'Account deletion is not allowed. Contact support.';
      }
      _setAuthError(errorMessage);
      _setLoading(false);
      print('Error deleting account: $errorMessage');
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      clearError();
      _setLoading(true);
      _status = AuthStatus.authenticating;
      notifyListeners();

      bool isGoogle = await isGoogleUser();

      if (isGoogle) {
        await _authRepository.reauthenticateWithGoogle();
        await _authRepository.changePassword('', newPassword);
      } else {
        if (oldPassword.isEmpty) {
          throw Exception('Current password is required');
        }
        await _authRepository.changePassword(oldPassword, newPassword);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setAuthError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateUsername(String newUsername) async {
    try {
      clearError();
      _setLoading(true);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      await _authRepository.updateUsername(user.uid, newUsername);
      await _refreshUser();
      _setLoading(false);
      return true;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('username-already-in-use')) {
        _setAuthError('This username is already taken. Please choose another.');
      } else {
        _setAuthError(errorMessage);
      }
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateEmail(String newEmail, String password) async {
    try {
      clearError();
      _setLoading(true);
      print('AuthProvider: Starting email update to $newEmail');
      await _authRepository.updateEmail(newEmail, password);
      await _refreshUser();
      _setLoading(false);
      print('AuthProvider: Email update successful');
      notifyListeners();
      return true;
    } catch (e) {
      String errorMessage = e.toString();
      print('AuthProvider: Email update failed with error: $errorMessage');
      if (errorMessage.contains('wrong-password')) {
        errorMessage = 'The password you entered is incorrect.';
      } else if (errorMessage.contains('operation-not-allowed')) {
        errorMessage =
            'Email update is not allowed. Please check Firebase settings or contact support.';
      } else if (errorMessage.contains('email-already-in-use')) {
        errorMessage =
            'This email address is already in use by another account.';
      } else if (errorMessage.contains('invalid-email')) {
        errorMessage = 'The email address is invalid.';
      } else if (errorMessage.contains('network-request-failed')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (errorMessage.contains('permission-denied')) {
        errorMessage = 'Permission denied. Please check Firestore settings.';
      } else if (errorMessage.contains('no-user-signed-in-after-reauth')) {
        errorMessage = 'User session lost. Please sign in again.';
      }
      _setAuthError(errorMessage);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      clearError();
      _setLoading(true);
      await _authRepository.sendEmailVerification();
      await _refreshUser();
      _setLoading(false);
      return true;
    } catch (e) {
      _setAuthError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> _refreshUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      //await firebaseUser.reload();
      final updatedFirebaseUser = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (updatedFirebaseUser != null && userDoc.exists) {
        // Mengambil username dari Firestore dengan logika default
        String username = userDoc.data()?['username'];

        // If username is null or empty, use the email prefix or 'User'
        if (username.isEmpty) {
          // Use the email prefix as username if available
          // Otherwise, use 'User' as default username
          username = updatedFirebaseUser.email != null &&
                  updatedFirebaseUser.email!.isNotEmpty
              ? updatedFirebaseUser.email!.split('@')[0]
              : 'User';
        }

        _user = UserEntity(
          uid: updatedFirebaseUser.uid,
          email: updatedFirebaseUser.email ?? '',
          username: username, // Gunakan username yang sudah diperiksa
          isEmailVerified: updatedFirebaseUser.emailVerified,
          profilePictureUrl: userDoc.data()?['profilePictureUrl'] ??
              'initial:${username[0]}', // Gunakan huruf pertama dari username yang sudah diperiksa
        );
        _status = AuthStatus.authenticated;
        print(
            'User refreshed: ${_user?.email}, verified: ${_user?.isEmailVerified}, username: ${_user?.username}');
        notifyListeners();
      }
    }
  }

  Future<void> ensureValidToken() async {
    try {
      if (_user == null) {
        throw Exception('No user signed in');
      }
      final isValid = await _authRepository.isTokenValid();
      if (!isValid) {
        final isRefreshValid = await _authRepository.isRefreshTokenValid();
        if (!isRefreshValid) {
          await signOut();
          throw Exception('Refresh token expired. Please sign in again.');
        }
        await _authRepository.refreshAuthToken();
      }
    } catch (e) {
      _setAuthError('Failed to ensure valid token: $e');
      notifyListeners();
      rethrow;
    }
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.contains(' ')) {
      return 'Username cannot contain spaces';
    }
    final validCharacters = RegExp(r'^[a-zA-Z0-9._]+$');
    if (!validCharacters.hasMatch(value)) {
      return 'Username can only contain letters, numbers, dots, and underscores';
    }
    return null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setAuthError(String message) {
    _errorMessage = message;
    _status = _user != null ? AuthStatus.authenticated : AuthStatus.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _isPostAuthAction = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopEmailVerificationPolling();
    super.dispose();
  }
}
