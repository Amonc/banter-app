import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ChatAnalyzer {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get _apiKey => dotenv.env['API_KEY'] ?? '';

  /// Analyzes a chat file using the backend API
  ///
  /// Takes a [File] object and sends it to the analyze endpoint
  /// Returns the analysis result as a Map
  ///
  /// Throws [Exception] if the request fails
  static Future<Map<String, dynamic>> analyzeChat(File file) async {
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
        return json.decode(response.body) as Map<String, dynamic>;
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
  /// Returns the analysis result as a Map
  ///
  /// Throws [Exception] if the file doesn't exist or request fails
  static Future<Map<String, dynamic>> analyzeChatFromPath(
    String filePath,
  ) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    return analyzeChat(file);
  }
}
