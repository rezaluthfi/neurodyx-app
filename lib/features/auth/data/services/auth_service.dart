import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/user_entity.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final String baseUrl = dotenv.env['BASE_URL_API'] ?? '';

  // Convert Firebase User to UserEntity
  UserEntity? _userFromFirebase(User? user, {String? username}) {
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      username: username,
      isEmailVerified: user.emailVerified,
      profilePictureUrl: user.photoURL ?? _generateProfilePictureUrl(username),
    );
  }

  // Generate default profile picture placeholder
  String _generateProfilePictureUrl(String? username) {
    if (username == null || username.isEmpty) return 'initial:?';
    return 'initial:${username[0].toUpperCase()}';
  }

  // Get user with username and profile picture from Firestore
  Future<UserEntity?> _userFromFirebaseWithUsername(User? user) async {
    if (user == null) return null;
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final username = userDoc.data()?['username'] as String?;
      final profilePictureUrl =
          userDoc.data()?['profilePictureUrl'] as String? ??
              user.photoURL ??
              _generateProfilePictureUrl(username);

      return UserEntity(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        username: username,
        isEmailVerified: user.emailVerified,
        profilePictureUrl: profilePictureUrl,
      );
    } catch (e) {
      return _userFromFirebase(user);
    }
  }

  // Stream for auth state changes
  Stream<UserEntity?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap(_userFromFirebaseWithUsername);

  // Get the current user
  Future<UserEntity?> get currentUser async {
    final user = _firebaseAuth.currentUser;
    return await _userFromFirebaseWithUsername(user);
  }

  // Authenticate with backend
  Future<Map<String, dynamic>> authenticateWithBackend({
    required String token,
    required String authType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'authType': authType,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to authenticate with backend: ${response.body}');
      }
    } catch (e) {
      throw Exception('Backend authentication error: $e');
    }
  }

  // Refresh token with backend
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to refresh token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Token refresh error: $e');
    }
  }

  // Sign in with email and password
  Future<UserEntity?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userEntity =
          await _userFromFirebaseWithUsername(userCredential.user);
      if (userEntity == null) {
        throw Exception('no-firestore-document');
      }

      return userEntity;
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Register with email, password, and username
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
        final profilePictureUrl = _generateProfilePictureUrl(username);
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'profilePictureUrl': profilePictureUrl,
        });
      }

      return _userFromFirebase(userCredential.user, username: username);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Generate unique username
  Future<String> _generateUniqueUsername(String baseUsername) async {
    String username = baseUsername
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    if (username.isEmpty) {
      username = 'user_${Random().nextInt(10000)}';
    }

    int attempt = 0;
    String candidate = username;
    while (true) {
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: candidate)
          .get();
      if (usernameQuery.docs.isEmpty) {
        return candidate;
      }
      attempt++;
      candidate = '$username${Random().nextInt(10000)}';
      if (attempt > 5) {
        throw Exception('failed-to-generate-unique-username');
      }
    }
  }

  // Sign in with Google
  Future<UserEntity?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        throw Exception('google-sign-in-cancelled');
      }
      print('Google user signed in: ${googleUser.email}');

      print('Fetching Google authentication credentials...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
          'Google auth credentials: idToken=${googleAuth.idToken != null}, accessToken=${googleAuth.accessToken != null}');
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        print('Failed to obtain Google ID token or access token');
        throw Exception('failed-to-obtain-google-tokens');
      }

      print('Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase with Google credential...');
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      print('Firebase sign-in successful: ${userCredential.user?.email}');

      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        if (!userDoc.exists) {
          print('Creating new Firestore user document...');
          String baseUsername = userCredential.user!.email!.split('@')[0];
          final username = await _generateUniqueUsername(baseUsername);
          final profilePictureUrl = userCredential.user!.photoURL ??
              _generateProfilePictureUrl(username);
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'username': username,
            'email': userCredential.user!.email!,
            'createdAt': FieldValue.serverTimestamp(),
            'profilePictureUrl': profilePictureUrl,
          });
          print('Firestore user document created');
        }
      }

      return await _userFromFirebaseWithUsername(userCredential.user);
    } catch (e) {
      print('Google Sign-In error: $e');
      throw _handleException(e);
    }
  }

  Future<String?> getGoogleIdToken() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        throw Exception('google-sign-in-cancelled');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.idToken == null) {
        print('Failed to obtain Google ID token');
        throw Exception('failed-to-obtain-google-id-token');
      }
      print('Google ID token obtained: ${googleAuth.idToken}');
      return googleAuth.idToken;
    } catch (e) {
      print('Error getting Google ID token: $e');
      rethrow;
    }
  }

  // Update profile picture placeholder
  Future<void> updateProfilePicture(String uid, String username) async {
    try {
      final profilePictureUrl = _generateProfilePictureUrl(username);
      await _firestore.collection('users').doc(uid).update({
        'profilePictureUrl': profilePictureUrl,
      });
    } catch (e) {
      throw Exception('Failed to update profile picture: $e');
    }
  }

  // Update username
  Future<void> updateUsername(String uid, String newUsername) async {
    try {
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: newUsername)
          .get();
      if (usernameQuery.docs.isNotEmpty) {
        throw Exception('username-already-in-use');
      }

      await _firestore.collection('users').doc(uid).update({
        'username': newUsername,
        'profilePictureUrl': _generateProfilePictureUrl(newUsername),
      });
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail, String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('no-user-signed-in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      await user.updateEmail(newEmail);

      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
      });

      await user.reload();
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

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Delete user account and Firestore data
  Future<void> deleteAccount({String? password}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('no-user-signed-in');
      }

      bool isGoogleUser = user.providerData
          .any((provider) => provider.providerId == 'google.com');
      if (!isGoogleUser) {
        if (password == null || password.isEmpty) {
          throw Exception('password-required');
        }
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      await _firestore.collection('users').doc(user.uid).delete();

      await user.delete();

      await _googleSignIn.signOut();
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.disconnect();
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

      if (hasPasswordProvider) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      } else if (isGoogleUser) {
        await reauthenticateWithGoogle();
        final passwordCredential = EmailAuthProvider.credential(
          email: email,
          password: newPassword,
        );
        try {
          await user.linkWithCredential(passwordCredential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'provider-already-linked') {
            await user.updatePassword(newPassword);
          } else {
            throw e;
          }
        }
      } else {
        throw Exception('no-supported-provider');
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Reauthenticate with Google
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

      final providerData = user.providerData;
      return providerData
          .any((provider) => provider.providerId == 'google.com');
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Reauthenticate with email and password
  Future<void> reauthenticateWithEmailPassword(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('no-user-signed-in');
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Handle all exceptions with custom messages
  String _handleException(dynamic e) {
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
          return 'This email address is already in use by another account.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'operation-not-allowed':
          return 'This operation is not allowed. Please check Firebase Authentication settings or contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'requires-recent-login':
          return 'This operation requires a recent login. Please sign in again.';
        case 'account-exists-with-different-credential':
          return 'This email is already registered with a different sign-in method.';
        case 'credential-already-in-use':
          return 'This email is already associated with another account.';
        case 'provider-already-linked':
          return 'This authentication provider is already linked to your account.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        default:
          return 'An authentication error occurred: ${e.message ?? e.code}';
      }
    }

    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'Permission denied. Please check Firestore security rules.';
        case 'unavailable':
          return 'Firestore service is unavailable. Please try again later.';
        default:
          return 'A Firestore error occurred: ${e.message ?? e.code}';
      }
    }

    if (e is PlatformException) {
      if (e.code == 'sign_in_failed' &&
          e.message?.contains('ApiException: 12500') == true) {
        return 'Google Sign-In failed: Please check Google Play Services.';
      }
      return 'Platform error occurred: ${e.message ?? e.code}';
    }

    if (e is TimeoutException) {
      return 'Operation timed out. Please check your network and try again.';
    }

    if (e.toString().contains('Exception:')) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      switch (errorMessage) {
        case 'username-already-in-use':
          return 'This username is already taken. Please choose another one.';
        case 'google-sign-in-cancelled':
          return 'Google Sign-In was cancelled by the user.';
        case 'no-user-signed-in':
          return 'No user is currently signed in.';
        case 'no-user-signed-in-after-reauth':
          return 'User session lost after reauthentication. Please sign in again.';
        case 'no-user-or-email-verified':
          return 'No user is signed in or the email is already verified.';
        case 'no-email-associated':
          return 'No email is associated with this account.';
        case 'no-supported-provider':
          return 'No supported authentication provider found for this account.';
        case 'no-firestore-document':
          return 'Account does not exist. Please register again.';
        case 'password-required':
          return 'Password is required for email/password account deletion.';
        case 'failed-to-generate-unique-username':
          return 'Failed to generate a unique username. Please try again.';
        default:
          return 'An error occurred: $errorMessage';
      }
    }

    return 'An unexpected error occurred: $e';
  }
}
