import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:banter/model/chat_analysis_response.dart';
import 'package:banter/model/chat_message.dart';

/// Base exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

/// Thrown when the input is too large (413)
class InputTooLargeException extends ApiException {
  InputTooLargeException([String? message])
    : super(
        message ??
            'The chat file is too large to process. Try using a smaller file or reducing the number of messages.',
        413,
      );
}

/// Thrown when AI processing fails (422)
class AIProcessingException extends ApiException {
  AIProcessingException([String? message])
    : super(message ?? 'Failed to process the chat. Please try again.', 422);
}

/// Thrown when rate limit is exceeded (429)
class RateLimitException extends ApiException {
  RateLimitException([String? message])
    : super(
        message ?? 'Too many requests. Please wait a moment and try again.',
        429,
      );
}

/// Thrown when service is unavailable (503)
class ServiceUnavailableException extends ApiException {
  ServiceUnavailableException([String? message])
    : super(
        message ??
            'Service is temporarily unavailable. Please try again later.',
        503,
      );
}

/// Thrown for authentication errors (401/403)
class AuthenticationException extends ApiException {
  AuthenticationException([String? message])
    : super(message ?? 'Authentication failed. Please contact support.', 401);
}

class ChatAnalyzer {
  static String get _baseUrl {
    if (!kDebugMode) {
      return dotenv.env['API_BASE_URL'] ?? '';
    }
    // In debug mode, use 10.0.2.2 for Android emulator (maps to host localhost)
    // and localhost for iOS simulator (shares host network)
    final localUrl = dotenv.env['LOCAL_API_BASE_URL'] ?? '';
    if (Platform.isAndroid) {
      return localUrl.replaceFirst('localhost', '10.0.2.2');
    }
    return localUrl;
  }

  static String get _apiKey => dotenv.env['API_KEY'] ?? '';

  /// Parses error response and throws the appropriate exception
  static Never _handleErrorResponse(http.Response response) {
    String? detail;
    try {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      detail = jsonBody['detail'] as String?;
    } catch (_) {
      // Body is not JSON, use as-is
      detail = response.body;
    }

    switch (response.statusCode) {
      case 401:
      case 403:
        throw AuthenticationException(detail);
      case 413:
        throw InputTooLargeException(detail);
      case 422:
        throw AIProcessingException(detail);
      case 429:
        throw RateLimitException(detail);
      case 503:
        throw ServiceUnavailableException(detail);
      default:
        throw ApiException(
          detail ?? 'Request failed with status ${response.statusCode}',
          response.statusCode,
        );
    }
  }

  /// Analyzes a chat file using the backend API
  ///
  /// Takes a [File] object and sends it to the analyze endpoint
  /// Returns the analysis result as a [ChatAnalysisResponse]
  ///
  /// Throws [Exception] if the request fails
  static Future<ChatAnalysisResponse> analyzeChat(File file, {int? sampleSize}) async {
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

      // Add form fields
      if (sampleSize != null) {
        request.fields['sample_size'] = sampleSize.toString();
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        return ChatAnalysisResponse.fromJson(jsonResponse);
      } else {
        _handleErrorResponse(response);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error analyzing chat: $e', 0);
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
    int? sampleSize,
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
      if (sampleSize != null) {
        request.fields['sample_size'] = sampleSize.toString();
      }

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
        _handleErrorResponse(response);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error sending chat message: $e', 0);
    }
  }
}
