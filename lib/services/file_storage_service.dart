import 'dart:io';
import 'package:banter/model/chat_analysis_response.dart';

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
}
