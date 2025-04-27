import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  // FirebaseAuth instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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

  Future<bool> isGoogleUser() async {
    try {
      final currentUser = await _authRepository.currentUser;
      if (currentUser != null) {
        // Implementasi untuk cek apakah user berasal dari Google
        return await _authRepository.isUserFromGoogle();
      }
      return false;
    } catch (e) {
      _setAuthError(e.toString());
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

  // Reauthenticate with Google
  Future<bool> reauthenticateWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn(); // <-- HARUS .signIn(), bukan silent
      if (googleUser == null) {
        // User canceled the sign-in
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        _setAuthError('User not found. Please sign in again.');
        return false;
      }

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      _setAuthError(e.toString());
      return false;
    }
  }

  // Reauthenticate with email and password
  Future<bool> reauthenticateWithEmailPassword(String password) async {
    try {
      await _authRepository.reauthenticateWithEmailPassword(password);
      return true;
    } catch (e) {
      _setAuthError(e.toString());
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
      await _authRepository.signOut(); // Sign out after deletion

      _user = null; // Set user to null after deletion
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      notifyListeners();

      return true;
    } catch (e) {
      _setAuthError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      clearError();
      _setLoading(true);
      _status = AuthStatus.authenticating;
      notifyListeners();

      // Cek apakah user menggunakan Google
      bool isGoogle = await isGoogleUser();

      if (isGoogle) {
        // Jika pengguna Google, kita perlu melakukan re-authentication
        await _authRepository.reauthenticateWithGoogle();
        await _authRepository.changePassword(
            '', newPassword); // Password lama diabaikan untuk pengguna Google
      } else {
        // Jika bukan pengguna Google, kita butuh password lama untuk mengganti password
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
