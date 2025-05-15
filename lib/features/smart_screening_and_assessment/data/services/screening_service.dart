import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:neurodyx/features/auth/data/repositories/auth_repository.dart';
import '../models/screening_question_model.dart';
import '../models/screening_result_model.dart';

class ScreeningService {
  final String baseUrl = dotenv.env['BASE_URL_API'] ?? '';
  final AuthRepository _authRepository;

  ScreeningService(this._authRepository);

  Future<String> _getValidToken() async {
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
  }

  Future<List<QuestionModel>> fetchQuestions(String ageGroup) async {
    try {
      final token = await _getValidToken();

      final response = await http.get(
        Uri.parse('$baseUrl/screening/questions?ageGroup=$ageGroup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => QuestionModel.fromJson(json)).toList();
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
          Uri.parse('$baseUrl/screening/questions?ageGroup=$ageGroup'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );

        if (retryResponse.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(retryResponse.body);
          return jsonList.map((json) => QuestionModel.fromJson(json)).toList();
        } else {
          throw Exception(
              'Failed to fetch questions after refresh: ${retryResponse.body}');
        }
      } else {
        throw Exception(
            'Failed to fetch questions: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  Future<ScreeningResultModel> submitAnswers(
      List<bool> answers, String ageGroup) async {
    try {
      if (answers.isEmpty) {
        throw Exception('Answers cannot be empty');
      }
      if (answers.length > 50) {
        throw Exception('Answers exceed maximum limit of 50');
      }

      final token = await _getValidToken();

      final response = await http.post(
        Uri.parse('$baseUrl/screening/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'ageGroup': ageGroup,
          'answers': answers,
        }),
      );

      if (response.statusCode == 200) {
        return ScreeningResultModel.fromJson(jsonDecode(response.body));
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

        final retryResponse = await http.post(
          Uri.parse('$baseUrl/screening/submit'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
          body: jsonEncode({
            'ageGroup': ageGroup,
            'answers': answers,
          }),
        );

        if (retryResponse.statusCode == 200) {
          return ScreeningResultModel.fromJson(jsonDecode(retryResponse.body));
        } else {
          throw Exception(
              'Failed to submit answers after refresh: ${retryResponse.body}');
        }
      } else {
        throw Exception(
            'Failed to submit answers: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting answers: $e');
    }
  }
}
