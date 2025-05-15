import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:neurodyx/features/auth/data/repositories/auth_repository.dart';
import '../models/therapy_category_model.dart';
import '../models/therapy_question_model.dart';
import '../models/therapy_result_model.dart';

class TherapyService {
  final String baseUrl = dotenv.env['BASE_URL_API'] ?? '';
  final AuthRepository _authRepository;

  TherapyService(this._authRepository);

  Future<String> _getValidToken() async {
    try {
      final isValid = await _authRepository.isTokenValid();
      if (!isValid) {
        final isRefreshValid = await _authRepository.isRefreshTokenValid();
        if (!isRefreshValid) {
          throw Exception('Refresh token expired. Please sign in again.');
        }
        await _authRepository.refreshAuthToken();
      }
      final token = await _authRepository.getToken();
      if (token == null) {
        throw Exception('No token available. Please sign in.');
      }
      return token;
    } catch (e, stackTrace) {
      debugPrint('Error getting token: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<TherapyCategoryModel>> fetchCategories(String type) async {
    try {
      final token = await _getValidToken();
      final response = await http.get(
        Uri.parse('$baseUrl/therapy/categories?type=$type'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
          'fetchCategories response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => TherapyCategoryModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        final isRefreshValid = await _authRepository.isRefreshTokenValid();
        if (!isRefreshValid) {
          throw Exception('Refresh token expired. Please sign in again.');
        }
        await _authRepository.refreshAuthToken();
        final newToken = await _authRepository.getToken();
        if (newToken == null) {
          throw Exception('Failed to obtain new token');
        }

        final retryResponse = await http.get(
          Uri.parse('$baseUrl/therapy/categories?type=$type'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );

        debugPrint(
            'fetchCategories retry response: ${retryResponse.statusCode} ${retryResponse.body}');

        if (retryResponse.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(retryResponse.body);
          return jsonList
              .map((json) => TherapyCategoryModel.fromJson(json))
              .toList();
        } else {
          throw Exception(
              'Failed to fetch categories: ${retryResponse.statusCode} ${retryResponse.body}');
        }
      } else {
        throw Exception(
            'Failed to fetch categories: ${response.statusCode} ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching categories: $e\n$stackTrace');
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<List<TherapyQuestionModel>> fetchQuestions(
      String type, String category) async {
    try {
      final token = await _getValidToken();
      final response = await http.get(
        Uri.parse('$baseUrl/therapy/questions?type=$type&category=$category'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
          'fetchQuestions response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => TherapyQuestionModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        final isRefreshValid = await _authRepository.isRefreshTokenValid();
        if (!isRefreshValid) {
          throw Exception('Refresh token expired. Please sign in again.');
        }
        await _authRepository.refreshAuthToken();
        final newToken = await _authRepository.getToken();
        if (newToken == null) {
          throw Exception('Failed to obtain new token');
        }

        final retryResponse = await http.get(
          Uri.parse('$baseUrl/therapy/questions?type=$type&category=$category'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );

        debugPrint(
            'fetchQuestions retry response: ${retryResponse.statusCode} ${retryResponse.body}');

        if (retryResponse.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(retryResponse.body);
          return jsonList
              .map((json) => TherapyQuestionModel.fromJson(json))
              .toList();
        } else {
          throw Exception(
              'Failed to fetch questions: ${retryResponse.statusCode} ${retryResponse.body}');
        }
      } else {
        throw Exception(
            'Failed to fetch questions: ${response.statusCode} ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching questions: $e\n$stackTrace');
      throw Exception('Error fetching questions: $e');
    }
  }

  Future<TherapyResultModel> submitAnswers(String type, String category,
      List<Map<String, dynamic>> submissions) async {
    try {
      final token = await _getValidToken();
      final body = jsonEncode({
        'type': type,
        'category': category,
        'submissions': submissions,
      });
      debugPrint(
          'Submitting answers to $baseUrl/therapy/submit with body: $body');
      final response = await http.post(
        Uri.parse('$baseUrl/therapy/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      debugPrint(
          'submitAnswers response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['result'] == null) {
          throw Exception('Response missing "result" key: ${response.body}');
        }
        return TherapyResultModel.fromJson(jsonData['result']);
      } else if (response.statusCode == 401) {
        final isRefreshValid = await _authRepository.isRefreshTokenValid();
        if (!isRefreshValid) {
          throw Exception('Refresh token expired. Please sign in again.');
        }
        await _authRepository.refreshAuthToken();
        final newToken = await _getValidToken();
        debugPrint('Retrying with new token: $newToken');
        final retryResponse = await http.post(
          Uri.parse('$baseUrl/therapy/submit'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
          body: body,
        );

        debugPrint(
            'submitAnswers retry response: ${retryResponse.statusCode} ${retryResponse.body}');

        if (retryResponse.statusCode == 200) {
          final jsonData = jsonDecode(retryResponse.body);
          if (jsonData['result'] == null) {
            throw Exception(
                'Retry response missing "result" key: ${retryResponse.body}');
          }
          return TherapyResultModel.fromJson(jsonData['result']);
        } else {
          throw Exception(
              'Failed to submit answers: ${retryResponse.statusCode} ${retryResponse.body}');
        }
      } else {
        throw Exception(
            'Failed to submit answers: ${response.statusCode} ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error submitting answers: $e\n$stackTrace');
      throw Exception('Error submitting answers: $e');
    }
  }

  Future<TherapyResultModel> fetchResults(String type, String category) async {
    try {
      final token = await _getValidToken();
      final response = await http.get(
        Uri.parse('$baseUrl/therapy/results?type=$type&category=$category'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
          'fetchResults response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData == null) {
          throw Exception('Empty response body');
        }
        return TherapyResultModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        final isRefreshValid = await _authRepository.isRefreshTokenValid();
        if (!isRefreshValid) {
          throw Exception('Refresh token expired. Please sign in again.');
        }
        await _authRepository.refreshAuthToken();
        final newToken = await _getValidToken();
        final retryResponse = await http.get(
          Uri.parse('$baseUrl/therapy/results?type=$type&category=$category'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );

        debugPrint(
            'fetchResults retry response: ${retryResponse.statusCode} ${retryResponse.body}');

        if (retryResponse.statusCode == 200) {
          final jsonData = jsonDecode(retryResponse.body);
          if (jsonData == null) {
            throw Exception('Empty retry response body');
          }
          return TherapyResultModel.fromJson(jsonData);
        } else {
          throw Exception(
              'Failed to fetch results: ${retryResponse.statusCode} ${retryResponse.body}');
        }
      } else {
        throw Exception(
            'Failed to fetch results: ${response.statusCode} ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching results: $e\n$stackTrace');
      throw Exception('Error fetching results: $e');
    }
  }
}
