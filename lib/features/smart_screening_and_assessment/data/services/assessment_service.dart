import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../../../features/auth/data/repositories/auth_repository.dart';
import '../models/assessment_question_model.dart';
import '../models/assessment_result_model.dart';

class AssessmentService {
  final String baseUrl = dotenv.env['BASE_URL_API'] ?? '';
  final AuthRepository _authRepository;

  AssessmentService(this._authRepository);

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

  Future<List<AssessmentQuestionModel>> fetchQuestions() async {
    try {
      final token = await _getValidToken();
      final response = await http.get(
        Uri.parse('$baseUrl/assessment/questions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => AssessmentQuestionModel.fromJson(json))
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
          Uri.parse('$baseUrl/assessment/questions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );

        if (retryResponse.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(retryResponse.body);
          return jsonList
              .map((json) => AssessmentQuestionModel.fromJson(json))
              .toList();
        } else {
          throw Exception(
              'Failed to fetch questions: ${retryResponse.statusCode} ${retryResponse.body}');
        }
      } else {
        throw Exception(
            'Failed to fetch questions: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  Future<AssessmentResultModel> submitAnswers(
      String type, List<Map<String, dynamic>> submissions) async {
    try {
      final token = await _getValidToken();
      final response = await http.post(
        Uri.parse('$baseUrl/assessment/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'type': type,
          'submissions': submissions,
        }),
      );

      if (response.statusCode == 200) {
        return AssessmentResultModel.fromJson(
            jsonDecode(response.body)['result']);
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
          Uri.parse('$baseUrl/assessment/submit'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
          body: jsonEncode({
            'type': type,
            'submissions': submissions,
          }),
        );

        if (retryResponse.statusCode == 200) {
          return AssessmentResultModel.fromJson(
              jsonDecode(retryResponse.body)['result']);
        } else {
          throw Exception(
              'Failed to submit answers: ${retryResponse.statusCode} ${retryResponse.body}');
        }
      } else {
        throw Exception(
            'Failed to submit answers: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting answers: $e');
    }
  }

  Future<List<AssessmentResultModel>> fetchResults() async {
    try {
      final token = await _getValidToken();
      final response = await http.get(
        Uri.parse('$baseUrl/assessment/results'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => AssessmentResultModel.fromJson(json))
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
          Uri.parse('$baseUrl/assessment/results'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );

        if (retryResponse.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(retryResponse.body);
          return jsonList
              .map((json) => AssessmentResultModel.fromJson(json))
              .toList();
        } else {
          throw Exception(
              'Failed to fetch results: ${retryResponse.statusCode} ${retryResponse.body}');
        }
      } else {
        throw Exception(
            'Failed to fetch results: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching results: $e');
    }
  }
}
