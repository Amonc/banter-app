import 'dart:io';
import 'package:banter/model/chat_analysis_response.dart';
import 'package:banter/model/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to store the uploaded chat file and analysis data in memory
/// This allows the data to be accessible across different screens
class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _chatFilePathKey = 'chat_file_path';

  factory FileStorageService() {
    return _instance;
  }

  FileStorageService._internal();

  File? _uploadedChatFile;
  ChatAnalysisResponse? _analysisData;
  List<ChatMessage> _chatHistory = [];
  String? _chatSessionId;

  /// Check if onboarding has been completed (persisted)
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Mark onboarding as complete and save the chat file path (persisted)
  static Future<void> completeOnboarding(String? chatFilePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
    if (chatFilePath != null) {
      await prefs.setString(_chatFilePathKey, chatFilePath);
    }
  }

  /// Get the saved chat file path (persisted)
  static Future<String?> getSavedChatFilePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chatFilePathKey);
  }

  /// Reset onboarding status (for testing or re-onboarding)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompleteKey);
    await prefs.remove(_chatFilePathKey);
  }

  /// Initialize the service by restoring saved chat file if available
  Future<void> initializeFromStorage() async {
    final savedPath = await getSavedChatFilePath();
    if (savedPath != null) {
      final file = File(savedPath);
      if (await file.exists()) {
        _uploadedChatFile = file;
      }
    }
  }

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
