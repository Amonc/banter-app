import 'dart:io' as io;
import 'package:banter/backend/chat_func.dart';
import 'package:banter/model/chat_analysis_response.dart';
import 'package:banter/breakdown_screen.dart';
import 'package:banter/services/file_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

export 'package:banter/backend/chat_func.dart'
    show
        ApiException,
        InputTooLargeException,
        AIProcessingException,
        RateLimitException,
        ServiceUnavailableException,
        AuthenticationException;

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  late File file;
  late RiveWidgetController controller;
  bool isInitialized = false;
  bool isAnalyzing = false;
  ChatAnalysisResponse? analysisResult;
  String? errorMessage;

  ViewModelInstanceTrigger? _uploadClick;
  ViewModelInstanceTrigger? _openCook;
  ViewModelInstanceTrigger? _openGetReady;
  ViewModelInstanceString? _groupChatName;

  @override
  void initState() {
    super.initState();
    initRive();
  }

  void initRive() async {
    file = (await File.asset(
      "assets/tutorial.riv",
      riveFactory: Factory.rive,
    ))!;
    controller = RiveWidgetController(file);
    final vmi = controller.dataBind(DataBind.auto());

    _uploadClick = vmi.trigger('upload_click');

    _openCook = vmi.trigger('open_cook');

    _openGetReady = vmi.trigger('open_get_ready');

    _groupChatName = vmi.string('group_chat_name');
    _groupChatName?.value = 'Besties';

    // Listen for the trigger firing (caused by your Rive "Pointer Click" listener)
    _uploadClick!.addListener((bool _) {
      // Will be called each time your Rive button is clicked
      _pickAndUploadFile();
    });
    setState(() => isInitialized = true);

    // controller.advance(0);
    // await Future.delayed(Duration(seconds: 2));
    // controller = RiveWidgetController(
    //   file,
    //   stateMachineSelector: StateMachineSelector.byName("State Machine"),
    // );
    // setState(() {});
  }

  @override
  void dispose() {
    file.dispose();
    controller.dispose();
    super.dispose();
  }

  void _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        // User canceled the picker
        return;
      }

      setState(() {
        isAnalyzing = true;
        errorMessage = null;
      });

      // File selected, trigger cook animation
      _openCook!.trigger();

      // Upload and analyze the file
      final filePath = result.files.single.path!;
      final selectedFile = io.File(filePath);

      // Copy file to app's documents directory for persistence
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(filePath);
      final persistentPath = path.join(appDir.path, 'chat_file_$fileName');
      final persistentFile = await selectedFile.copy(persistentPath);

      // Save the file to memory for later use in chat screen
      final storageService = FileStorageService();
      storageService.saveChatFile(persistentFile);
      // Clear any existing chat history since we're starting with a new file
      storageService.clearChatHistory();

      try {
        final response = await ChatAnalyzer.analyzeChat(persistentFile);

        setState(() {
          analysisResult = response;
          isAnalyzing = false;
        });

        // Trigger get ready animation after analysis completes
        _openGetReady!.trigger();

        // Wait 5 seconds then navigate to breakdown screen
        await Future.delayed(const Duration(seconds: 5));

        if (mounted) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  BreakdownScreen(
                    analysisData: response,
                    showlastImmediately: false,
                  ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      } on InputTooLargeException catch (e) {
        _showError(e.message);
      } on RateLimitException catch (e) {
        _showError(e.message, isRetryable: true);
      } on ServiceUnavailableException catch (e) {
        _showError(e.message, isRetryable: true);
      } on ApiException catch (e) {
        _showError(e.message);
      } catch (e) {
        _showError('Failed to analyze chat. Please try again.');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error picking file: $e';
        isAnalyzing = false;
      });
    }
  }

  void _showError(String message, {bool isRetryable = false}) {
    setState(() {
      errorMessage = message;
      isAnalyzing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isRetryable ? Colors.orange.shade700 : Colors.red,
          duration: const Duration(seconds: 5),
          action: isRetryable
              ? SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: _pickAndUploadFile,
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: RiveWidget(controller: controller, fit: Fit.fitWidth),
    );
  }
}
