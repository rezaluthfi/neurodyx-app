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

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();
    } catch (e) {
      rethrow;
    }
  }
}
