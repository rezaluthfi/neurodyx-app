import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/progress_model.dart';
import 'dart:developer' as developer;
import 'package:neurodyx/features/auth/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  final String baseUrl = dotenv.env['BASE_URL_API'] ?? '';
  final AuthService authService;

  ProgressService({required this.authService});

  // Cache keys for tokens
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  Future<String> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenExpiry = prefs.getString(_tokenExpiryKey);
      final cachedToken = prefs.getString(_accessTokenKey);

      if (cachedToken != null && tokenExpiry != null) {
        final expiryDate = DateTime.parse(tokenExpiry);
        if (expiryDate.isAfter(DateTime.now())) {
          developer.log('Using cached token');
          return cachedToken;
        }

        final refreshToken = prefs.getString(_refreshTokenKey);
        if (refreshToken != null) {
          try {
            final refreshResult = await authService.refreshToken(refreshToken);
            await _saveTokens(refreshResult);
            return refreshResult['token']
                as String; // Ubah dari 'accessToken' ke 'token'
          } catch (e) {
            developer.log('Failed to refresh token: $e');
          }
        }
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        developer.log('No user is currently signed in');
        throw Exception('No user is signed in');
      }

      final isGoogleUser = await authService.isUserFromGoogle();
      String token;
      String authType;

      if (isGoogleUser) {
        final googleToken = await authService.getGoogleIdToken();
        if (googleToken == null) {
          throw Exception('Failed to obtain Google ID token');
        }
        token = googleToken;
        authType = 'google';
        developer.log('Using Google ID token for authentication');
      } else {
        final firebaseToken = await currentUser.getIdToken();
        if (firebaseToken == null) {
          developer.log('Failed to obtain Firebase ID token');
          throw Exception('Failed to obtain Firebase ID token');
        }
        token = firebaseToken;
        authType = 'firebase';
        developer.log('Using Firebase ID token for authentication');
      }

      final authResult = await authService.authenticateWithBackend(
        token: token,
        authType: authType,
      );

      if (!authResult.containsKey('token') || authResult['token'] == null) {
        developer.log('Backend did not return a valid token: $authResult');
        throw Exception('Backend did not return a valid token');
      }

      await _saveTokens(authResult);
      return authResult['token']
          as String; // Ubah dari 'accessToken' ke 'token'
    } catch (e) {
      developer.log('Error getting auth token: $e');
      throw Exception('Failed to get auth token: $e');
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> authResult) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save access token
      if (authResult.containsKey('token')) {
        await prefs.setString(_accessTokenKey, authResult['token']);
      }

      // Save refresh token
      if (authResult.containsKey('refreshToken')) {
        await prefs.setString(_refreshTokenKey, authResult['refreshToken']);
      }

      // Calculate and save expiry time
      if (authResult.containsKey('expiresIn')) {
        final expiresInSeconds = authResult['expiresIn'];
        final expiryDate =
            DateTime.now().add(Duration(seconds: expiresInSeconds));
        await prefs.setString(_tokenExpiryKey, expiryDate.toIso8601String());
      }
    } catch (e) {
      developer.log('Error saving tokens: $e');
    }
  }

  Future<List<WeeklyProgressModel>> fetchWeeklyProgress() async {
    developer.log('Fetching weekly progress from: $baseUrl/progress/weekly');
    try {
      final token = await _getAuthToken();

      final response = await http.get(
        Uri.parse('$baseUrl/progress/weekly'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WeeklyProgressModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Clear tokens on unauthorized and retry once
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_accessTokenKey);
        await prefs.remove(_refreshTokenKey);
        await prefs.remove(_tokenExpiryKey);

        // Try one more time with fresh token
        developer.log('Retrying fetchWeeklyProgress after clearing tokens');
        return await fetchWeeklyProgress();
      } else {
        throw Exception(
            'Failed to fetch weekly progress: Status ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching weekly progress: $e');
      throw Exception('Failed to fetch weekly progress: $e');
    }
  }

  Future<List<MonthlyProgressModel>> fetchMonthlyProgress() async {
    developer.log('Fetching monthly progress from: $baseUrl/progress/monthly');
    try {
      final token = await _getAuthToken();

      final response = await http.get(
        Uri.parse('$baseUrl/progress/monthly'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MonthlyProgressModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Clear tokens on unauthorized and retry once
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_accessTokenKey);
        await prefs.remove(_refreshTokenKey);
        await prefs.remove(_tokenExpiryKey);

        // Try one more time with fresh token
        developer.log('Retrying fetchMonthlyProgress after clearing tokens');
        return await fetchMonthlyProgress();
      } else {
        throw Exception(
            'Failed to fetch monthly progress: Status ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching monthly progress: $e');
      throw Exception('Failed to fetch monthly progress: $e');
    }
  }
}
