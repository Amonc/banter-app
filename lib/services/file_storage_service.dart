import 'dart:io';
import 'package:banter/model/chat_analysis_response.dart';
import 'package:banter/model/chat_message.dart';

/// Service to store the uploaded chat file and analysis data in memory
/// This allows the data to be accessible across different screens
class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();

  factory FileStorageService() {
    return _instance;
  }

  FileStorageService._internal();

  File? _uploadedChatFile;
  ChatAnalysisResponse? _analysisData;
  List<ChatMessage> _chatHistory = [];
  String? _chatSessionId;

  /// Save the uploaded chat file
  void saveChatFile(File file) {
    _uploadedChatFile = file;
  }

  /// Get the uploaded chat file
  File? getChatFile() {
    return _uploadedChatFile;
  }

  /// Check if a chat file has been uploaded
  bool hasChatFile() {
    return _uploadedChatFile != null;
  }

  /// Clear the stored chat file
  void clearChatFile() {
    _uploadedChatFile = null;
  }

  /// Save the analysis data
  void saveAnalysisData(ChatAnalysisResponse data) {
    _analysisData = data;
  }

  /// Get the analysis data
  ChatAnalysisResponse? getAnalysisData() {
    return _analysisData;
  }

  /// Check if analysis data exists
  bool hasAnalysisData() {
    return _analysisData != null;
  }

  /// Clear the analysis data
  void clearAnalysisData() {
    _analysisData = null;
  }

  /// Save the chat history
  void saveChatHistory(List<ChatMessage> messages) {
    _chatHistory = List.from(messages);
  }

  /// Get the chat history
  List<ChatMessage> getChatHistory() {
    return List.from(_chatHistory);
  }

  /// Check if chat history exists
  bool hasChatHistory() {
    return _chatHistory.isNotEmpty;
  }

  /// Clear the chat history
  void clearChatHistory() {
    _chatHistory = [];
    _chatSessionId = null;
  }

  /// Save the chat session ID
  void saveChatSessionId(String? sessionId) {
    _chatSessionId = sessionId;
  }

  /// Get the chat session ID
  String? getChatSessionId() {
    return _chatSessionId;
  }
}
