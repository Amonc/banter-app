import 'dart:io';

/// Service to store the uploaded chat file in memory
/// This allows the file to be accessible across different screens
class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();

  factory FileStorageService() {
    return _instance;
  }

  FileStorageService._internal();

  File? _uploadedChatFile;

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
}
