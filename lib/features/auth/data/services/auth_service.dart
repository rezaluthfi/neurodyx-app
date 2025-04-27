import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Convert Firebase User to UserEntity
  UserEntity? _userFromFirebase(User? user, {String? username}) {
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      username: username,
      isEmailVerified: user.emailVerified,
    );
  }

  // Stream for auth state changes
  Stream<UserEntity?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap(_userFromFirebaseWithUsername);

  // Get user with username from Firestore
  Future<UserEntity?> _userFromFirebaseWithUsername(User? user) async {
    if (user == null) return null;
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final username =
          userData != null ? userData['username'] as String? : null;

      return UserEntity(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        username: username,
        isEmailVerified: user.emailVerified,
      );
    } catch (e) {
      return _userFromFirebase(user);
    }
  }

  // Get the current user
  Future<UserEntity?> get currentUser async {
    final user = _firebaseAuth.currentUser;
    return await _userFromFirebaseWithUsername(user);
  }

  // Sign in with email and password
  Future<UserEntity?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _userFromFirebaseWithUsername(userCredential.user);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Register with email and password and username
  Future<UserEntity?> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw Exception('username-already-in-use');
      }

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return _userFromFirebase(userCredential.user, username: username);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Sign in with Google
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('google-sign-in-cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Check if the user already exists in Firestore
      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        // If the user does not exist, create a new document in Firestore
        if (!userDoc.exists) {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'username': userCredential.user!.displayName ?? googleUser.email,
            'email': userCredential.user!.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return await _userFromFirebaseWithUsername(userCredential.user);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.disconnect();
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else {
        throw Exception('no-user-or-email-verified');
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Delete user account and Firestore data
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await _googleSignIn.signOut();
        if (_googleSignIn.currentUser != null) {
          await _googleSignIn.disconnect();
        }
        await user.delete();
      } else {
        throw Exception('no-user-signed-in');
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('no-user-signed-in');
      }

      final email = user.email;
      if (email == null) {
        throw Exception('no-email-associated');
      }

      final providerData = user.providerData;
      bool hasPasswordProvider =
          providerData.any((provider) => provider.providerId == 'password');
      bool isGoogleUser =
          providerData.any((provider) => provider.providerId == 'google.com');

      print('User UID: ${user.uid}');
      print('User Email: ${user.email}');
      print('Providers: ${providerData.map((p) => p.providerId).toList()}');

      if (hasPasswordProvider) {
        // User already has email/password, normal change
        final credential = EmailAuthProvider.credential(
          email: email,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      } else if (isGoogleUser) {
        // Google user, no email/password yet
        try {
          await reauthenticateWithGoogle(); // very important!
        } catch (e) {
          throw Exception('google-reauthentication-failed: $e');
        }

        final passwordCredential = EmailAuthProvider.credential(
          email: email,
          password: newPassword,
        );

        try {
          print("Trying to link password credential to Google user...");
          await user.linkWithCredential(passwordCredential);
          print("Link success, now user has email/password provider!");
        } on FirebaseAuthException catch (e) {
          if (e.code == 'provider-already-linked') {
            // Already linked? Just update password
            print("Provider already linked. Updating password instead.");
            await user.updatePassword(newPassword);
          } else if (e.code == 'credential-already-in-use') {
            throw Exception('email-already-has-password-account');
          } else if (e.code == 'requires-recent-login') {
            throw Exception('please-logout-and-login-again');
          } else {
            throw Exception('link-password-failed: ${e.code}');
          }
        }
      } else {
        throw Exception('no-supported-provider');
      }
    } catch (e) {
      print('Error in changePassword: $e');
      throw _handleException(e);
    }
  }

  // Method to reauthenticate Google user
  Future<void> reauthenticateWithGoogle() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('no-user-signed-in');
      }

      GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      if (googleUser == null) {
        googleUser = await _googleSignIn.signInSilently();
        if (googleUser == null) {
          googleUser = await _googleSignIn.signIn();
          if (googleUser == null) {
            throw Exception('google-sign-in-cancelled');
          }
        }
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      print('Error in reauthenticateWithGoogle: $e');
      throw Exception('reauthenticate-google-failed: $e');
    }
  }

  // Check if user is from Google
  Future<bool> isUserFromGoogle() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return false;
      }

      // Check provider data
      final providerData = user.providerData;

      for (var provider in providerData) {
        if (provider.providerId == 'google.com') {
          return true;
        }
      }

      return false;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> reauthenticateWithEmailPassword(String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user logged in');
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  // Handle all exceptions with custom messages
  String _handleException(dynamic e) {
    // Handle FirebaseAuthException
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email. Please register first.';
        case 'wrong-password':
          return 'The password you entered is incorrect.';
        case 'invalid-credential':
          return 'The email or password is incorrect. Please try again.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'email-already-in-use':
          return 'The email address is already in use.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'operation-not-allowed':
          return 'Account creation is not allowed.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        case 'requires-recent-login':
          return 'This operation requires a recent login. Please sign in again.';
        case 'account-exists-with-different-credential':
          return 'This email is already registered with a different sign-in method. Please sign in with the original method.';
        case 'credential-already-in-use':
          return 'This email is already associated with another account.';
        case 'channel-error':
          return 'An error occurred during authentication. Please try logging out and logging in again.';
        case 'provider-already-linked':
          return 'This authentication provider is already linked to your account.';
        case 'email-already-exists':
          return 'The email address is already in use with a different account.';
        default:
          return 'An authentication error occurred: ${e.message ?? e.code}';
      }
    }

    // Handle PlatformException (from google_sign_in)
    if (e is PlatformException) {
      if (e.code == 'sign_in_failed' &&
          e.message?.contains('ApiException: 12500') == true) {
        return 'Google Sign-In failed: Please check if Google Play Services is up to date, an account is added to the device, and the SHA-1 fingerprint is correctly configured in Firebase Console.';
      }
      if (e.code == 'status' &&
          e.message?.contains('Failed to disconnect') == true) {
        return 'Failed to disconnect Google Sign-In session. This does not affect the operation.';
      }
      return 'Platform error occurred: ${e.message ?? e.code}';
    }

    // Handle custom exceptions
    if (e.toString().contains('Exception:')) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Handle custom error cases
      switch (errorMessage) {
        case 'username-already-in-use':
          return 'This username is already taken. Please choose another one.';
        case 'google-sign-in-cancelled':
          return 'Google Sign-In was cancelled by the user.';
        case 'no-user-signed-in':
          return 'No user is currently signed in.';
        case 'no-user-or-email-verified':
          return 'No user is signed in or the email is already verified.';
        case 'google-user-needs-reauthentication':
          return 'You need to sign in again with Google before setting a password.';
        case 'no-email-associated':
          return 'No email is associated with this account.';
        case 'google-auth-tokens-invalid':
          return 'Google authentication tokens are invalid. Please try again.';
        case 'email-already-has-password-account':
          return 'This email is already associated with a password account. Please use that account to sign in.';
        case 'please-logout-and-login-again':
          return 'For security reasons, please sign out and sign in again before setting a password.';
        case 'google-reauthentication-failed':
          return 'Failed to re-authenticate with Google. Please try signing out and signing in again.';
        case 'no-supported-provider':
          return 'No supported authentication provider found for this account.';
        default:
          if (errorMessage.startsWith('password-update-failed:')) {
            return 'Failed to update password: ${errorMessage.replaceAll('password-update-failed: ', '')}';
          }
          if (errorMessage.startsWith('unexpected-error:')) {
            return 'An unexpected error occurred. Please try again later.';
          }
          if (errorMessage.startsWith('reauthenticate-google-failed:')) {
            return 'Failed to re-authenticate with Google: ${errorMessage.replaceAll('reauthenticate-google-failed: ', '')}';
          }
          return 'An error occurred: $errorMessage';
      }
    }

    // Default case
    return 'An unexpected error occurred: $e';
  }
}
