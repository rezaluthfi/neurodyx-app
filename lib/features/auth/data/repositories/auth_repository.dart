import '../services/auth_service.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Stream<UserEntity?> get authStateChanges => _authService.authStateChanges;

  Future<UserEntity?> get currentUser => _authService.currentUser;

  Future<UserEntity?> signIn(String email, String password) async {
    try {
      return await _authService.signInWithEmailAndPassword(email, password);
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
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserEntity?> signInWithGoogle() async {
    try {
      return await _authService.signInWithGoogle();
    } catch (e) {
      rethrow;
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
