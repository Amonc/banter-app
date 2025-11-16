import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:banter/model/chat_analysis_response.dart';
import 'package:banter/model/chat_message.dart';

class ChatAnalyzer {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get _apiKey => dotenv.env['API_KEY'] ?? '';

  /// Analyzes a chat file using the backend API
  ///
  /// Takes a [File] object and sends it to the analyze endpoint
  /// Returns the analysis result as a [ChatAnalysisResponse]
  ///
  /// Throws [Exception] if the request fails
  static Future<ChatAnalysisResponse> analyzeChat(File file) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/analyze');

      var request = http.MultipartRequest('POST', uri);

      // Add API key header
      request.headers['X-API-Key'] = _apiKey;

      // Add file to request
      var fileStream = http.ByteStream(file.openRead());
      var fileLength = await file.length();
      var multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );

      request.files.add(multipartFile);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        return ChatAnalysisResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Failed to analyze chat: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error analyzing chat: $e');
    }
  }

  /// Analyzes a chat file from a file path
  ///
  /// Takes a [filePath] string and sends it to the analyze endpoint
  /// Returns the analysis result as a [ChatAnalysisResponse]
  ///
  /// Throws [Exception] if the file doesn't exist or request fails
  static Future<ChatAnalysisResponse> analyzeChatFromPath(
    String filePath,
  ) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    return analyzeChat(file);
  }

  /// Sends a chat message to the AI chat endpoint
  ///
  /// Takes a [File] object (chat history), [query] (user's message),
  /// and optional [sessionId] for continuing conversations
  /// Returns a [ChatResponse] with the AI's response and session ID
  ///
  /// Throws [Exception] if the request fails
  static Future<ChatResponse> sendChatMessage({
    required File file,
    required String query,
    String? sessionId,
    int sampleSize = 200,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/analyze/chat');

      var request = http.MultipartRequest('POST', uri);

      // Add API key header
      request.headers['X-API-Key'] = _apiKey;

      // Add file to request
      var fileStream = http.ByteStream(file.openRead());
      var fileLength = await file.length();
      var multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );

      request.files.add(multipartFile);

      // Add form fields
      request.fields['query'] = query;
      request.fields['sample_size'] = sampleSize.toString();

      if (sessionId != null && sessionId.isNotEmpty) {
        request.fields['session_id'] = sessionId;
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        return ChatResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Failed to send chat message: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error sending chat message: $e');
    }
  }
}
