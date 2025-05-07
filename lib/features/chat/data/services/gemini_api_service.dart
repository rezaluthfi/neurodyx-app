import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class GeminiApiService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String _baseUrl = dotenv.env['GEMINI_API_URL'] ?? '';

  Future<dynamic> sendMessage(String message, {List<dynamic>? history}) async {
    final url = Uri.parse('$_baseUrl?key=$apiKey');
    final headers = {
      'Content-Type': 'application/json',
    };

    // List for storing message history
    List<Map<String, dynamic>> contents = [];

    // Add previous messages to contents if available
    if (history != null && history.isNotEmpty) {
      for (var msg in history) {
        contents.add({
          'role': msg['role'],
          'parts': [
            {'text': msg['content']}
          ],
        });
      }
    }

    // Add new user message to contents
    contents.add({
      'role': 'user',
      'parts': [
        {'text': message}
      ],
    });

    // Prepare request body
    final requestBody = {
      'contents': contents,
    };

    try {
      // Log for debugging
      debugPrint('Sending request to Gemini API: $url');
      debugPrint('Request body: ${jsonEncode(requestBody)}');

      final response =
          await http.post(url, headers: headers, body: jsonEncode(requestBody));

      // Log respons for debugging
      debugPrint('Response status: ${response.statusCode}');
      debugPrint(
          'Response body preview: ${response.body.substring(0, response.body.length.clamp(0, 200))}...');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Network or parsing error: $e');
      throw Exception('Error communicating with Gemini API: $e');
    }
  }

  String extractResponseText(dynamic response) {
    try {
      debugPrint('Extracting text from response structure');

      // Ensure response is not null and has expected structure
      if (response == null) {
        debugPrint('Response is null');
        return 'No response received';
      }

      // Check if response contains 'candidates' and 'content'
      final candidates = response['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        debugPrint('No candidates in response');
        return 'No response content';
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      if (content == null) {
        debugPrint('No content in first candidate');
        return 'No response content';
      }

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        debugPrint('No parts in content');
        return 'No response content';
      }

      final text = parts[0]['text'] as String?;
      if (text == null || text.isEmpty) {
        debugPrint('No text in first part');
        return 'No response content';
      }

      return text;
    } catch (e) {
      debugPrint('Error extracting response text: $e');
      return 'Error processing response';
    }
  }
}
