import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../../domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Stream<UserEntity?> get authStateChanges => _authService.authStateChanges;

  Future<UserEntity?> get currentUser => _authService.currentUser;

  // Simpan token ke shared preferences
  Future<void> _saveTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setInt('tokenTimestamp', DateTime.now().millisecondsSinceEpoch);
  }

  // Ambil token dari shared preferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Ambil refresh token dari shared preferences
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  // Periksa apakah token masih valid (kurang dari 1 hari)
  Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenTimestamp = prefs.getInt('tokenTimestamp');
    if (tokenTimestamp == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final oneDayInMillis = 24 * 60 * 60 * 1000; // 1 hari
    return (now - tokenTimestamp) < oneDayInMillis;
  }

  // Periksa apakah refresh token masih valid (kurang dari 30 hari)
  Future<bool> isRefreshTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenTimestamp = prefs.getInt('tokenTimestamp');
    if (tokenTimestamp == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final thirtyDaysInMillis = 30 * 24 * 60 * 60 * 1000; // 30 hari
    return (now - tokenTimestamp) < thirtyDaysInMillis;
  }

  Future<UserEntity?> signIn(String email, String password) async {
    try {
      final user =
          await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        // Ambil token Firebase dari pengguna saat ini
        final firebaseUser = FirebaseAuth.instance.currentUser;
        final token = await firebaseUser?.getIdToken();
        if (token != null) {
          final backendResponse = await _authService.authenticateWithBackend(
            token: token,
            authType: 'firebase',
          );
          await _saveTokens(
              backendResponse['token'], backendResponse['refreshToken']);
        } else {
          throw Exception('Failed to obtain Firebase token');
        }
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserEntity?> register(
      String email, String password, String username) async {
    try {
      final user = await _authService.registerWithEmailAndPassword(
          email, password, username);
      await _authService.sendEmailVerification();
      if (user != null) {
        // Ambil token Firebase dari pengguna saat ini
        final firebaseUser = FirebaseAuth.instance.currentUser;
        final token = await firebaseUser?.getIdToken();
        if (token != null) {
          final backendResponse = await _authService.authenticateWithBackend(
            token: token,
            authType: 'firebase',
          );
          await _saveTokens(
              backendResponse['token'], backendResponse['refreshToken']);
        } else {
          throw Exception('Failed to obtain Firebase token');
        }
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserEntity?> signInWithGoogle() async {
    try {
      print('AuthRepository: Starting Google Sign-In...');
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        print('AuthRepository: Google Sign-In successful, fetching token...');
        final firebaseUser = FirebaseAuth.instance.currentUser;
        // Gunakan Google ID token untuk authType: 'google'
        final token = await _authService.getGoogleIdToken();
        if (token != null) {
          print(
              'AuthRepository: Google ID token obtained, authenticating with backend...');
          final backendResponse = await _authService.authenticateWithBackend(
            token: token,
            authType: 'google',
          );
          print('AuthRepository: Backend response: $backendResponse');
          await _saveTokens(
              backendResponse['token'], backendResponse['refreshToken']);
        } else {
          print('AuthRepository: Failed to obtain Google ID token');
          throw Exception('Failed to obtain Google ID token');
        }
      }
      return user;
    } catch (e) {
      print('AuthRepository: Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> refreshAuthToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token available');
      final backendResponse = await _authService.refreshToken(refreshToken);
      await _saveTokens(
          backendResponse['token'], backendResponse['refreshToken']);
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  Future<void> reauthenticateWithGoogle() async {
    try {
      await _authService.reauthenticateWithGoogle();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reauthenticateWithEmailPassword(String password) async {
    try {
      await _authService.reauthenticateWithEmailPassword(password);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserFromGoogle() async {
    try {
      return await _authService.isUserFromGoogle();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount({String? password}) async {
    try {
      await _authService.deleteAccount(password: password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _authService.changePassword(oldPassword, newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUsername(String uid, String newUsername) async {
    try {
      await _authService.updateUsername(uid, newUsername);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmail(String newEmail, String password) async {
    try {
      await _authService.updateEmail(newEmail, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfilePicture(String uid, String username) async {
    try {
      await _authService.updateProfilePicture(uid, username);
    } catch (e) {
      rethrow;
    }
  }
}
