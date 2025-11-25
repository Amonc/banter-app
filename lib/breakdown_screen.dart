import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:banter/model/chat_analysis_response.dart';

/// Enum to track which breakdown is currently active
enum BreakdownState {
  breakdown1,
  breakdown2,
  breakdown4,
}

/// Custom controller that allows pausing animation while keeping pointer events active
base class PausableRiveController extends RiveWidgetController {
  PausableRiveController(super.file);

  bool _isPaused = false;

  void pauseAnimation() {
    _isPaused = true;
  }

  void resumeAnimation() {
    _isPaused = false;
    scheduleRepaint(); // Ensure animation continues
  }

  @override
  bool advance(double elapsedSeconds) {
    if (_isPaused) {
      // Still process state machine but don't advance time
      return active;
    }
    return super.advance(elapsedSeconds);
  }
}

class BreakdownScreen extends StatefulWidget {
  final ChatAnalysisResponse analysisData;

  const BreakdownScreen({super.key, required this.analysisData});

  @override
  State<BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends State<BreakdownScreen> {
  late File file;
  late PausableRiveController controller;
  bool isInitialized = false;

  // Track active breakdown state
  BreakdownState _currentBreakdown = BreakdownState.breakdown1;

  // Trigger references
  ViewModelInstanceTrigger? _breakdown1Trigger;
  ViewModelInstanceTrigger? _breakdown2Trigger;
  ViewModelInstanceTrigger? _breakdown4Trigger;
  

  @override
  void initState() {
    super.initState();
    initRive();
  }

  void _goToNext() {
    switch (_currentBreakdown) {
      case BreakdownState.breakdown1:
        _breakdown2Trigger?.trigger();
        break;
      case BreakdownState.breakdown2:
        _breakdown4Trigger?.trigger();
        break;
      case BreakdownState.breakdown4:
        // Already at the last breakdown, do nothing
        break;
    }
  }

  void _goToPrevious() {
    switch (_currentBreakdown) {
      case BreakdownState.breakdown1:
        // Already at the first breakdown, do nothing
        break;
      case BreakdownState.breakdown2:
        _breakdown1Trigger?.trigger();
        break;
      case BreakdownState.breakdown4:
        _breakdown2Trigger?.trigger();
        break;
    }
  }

  /// Extracts the first name from a full name
  /// e.g., "John Doe" -> "John", "~ Alice Smith" -> "Alice"
  String getFirstName(String fullName) {
    // Remove leading special characters like ~, @, etc.
    String cleanName = fullName.trim().replaceAll(RegExp(r'^[~@#$%^&*]+\s*'), '');

    // Split by space and take the first part
    final parts = cleanName.split(' ');
    return parts.isNotEmpty ? parts[0] : fullName;
  }

  void initRive() async {
    file = (await File.asset(
      "assets/breakdown_1.riv",
      riveFactory: Factory.rive,
    ))!;
    controller = PausableRiveController(file);
    final vmi = controller.dataBind(DataBind.auto());

    // Get trigger references
    _breakdown1Trigger = vmi.trigger('breakdown_1_enter');
    _breakdown2Trigger = vmi.trigger('breakdown_2_enter');
    _breakdown4Trigger = vmi.trigger('breakdown_4_enter');

    // Bind all the VMI strings for breakdown_1
    final typoMachine = vmi.string('typo_machine');
    final mostSentCount = vmi.string('most_send_count');
    final mostSenderName = vmi.string('most_sender_name');
    final groupChatName = vmi.string('group_chat_name');
    final textsPerDay = vmi.string('texts_per_day');
    final totalMessageCount = vmi.string('total_message_count');
    final mostActiveDay = vmi.string('most_active_day');

    // Set values from actual analysis data
    final data = widget.analysisData;
    typoMachine?.value = getFirstName(data.loudestMember.name);
    mostSentCount?.value = 'SENT ${data.loudestMember.count} MESSAGES';
    mostSenderName?.value = getFirstName(data.loudestMember.name);
    groupChatName?.value = data.groupChatName;
    textsPerDay?.value = data.messageStats.avgMessagesPerDay.toStringAsFixed(1);
    totalMessageCount?.value = data.messageStats.totalMessages.toString();
    mostActiveDay?.value = data.messageStats.mostActiveDay;

    // Listen for state machine state changes
    // When the state machine transitions to a new state, update _currentBreakdown
    controller.stateMachine.addEventListener((event) {
      print('State changed: ${event.name}');

      // Update the current breakdown based on the state name
      switch (event.name) {
        case 'breakdown_1':
          if (_currentBreakdown != BreakdownState.breakdown1) {
            setState(() => _currentBreakdown = BreakdownState.breakdown1);
          }
          break;
        case 'breakdown_2':
          if (_currentBreakdown != BreakdownState.breakdown2) {
            setState(() => _currentBreakdown = BreakdownState.breakdown2);
          }
          break;
        case 'breakdown_4':
          if (_currentBreakdown != BreakdownState.breakdown4) {
            setState(() => _currentBreakdown = BreakdownState.breakdown4);
          }
          break;
      }
    });

    setState(() => isInitialized = true);


  }


  @override
  void dispose() {
    file.dispose();
    controller.dispose();
    super.dispose();
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
      body: GestureDetector(
        onTapUp: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          final tapPosition = details.globalPosition.dx;

          // Instagram-style tap areas:
          // Left 1/3 of screen: go previous
          // Right 2/3 of screen: go next
          if (tapPosition < screenWidth / 3) {
            _goToPrevious();
          } else {
            _goToNext();
          }
        },
        child: Listener(
          onPointerDown: (_) {
            // Pause animation when touching the screen
            controller.pauseAnimation();
          },
          onPointerUp: (_) {
            // Resume animation when releasing
            controller.resumeAnimation();
          },
          onPointerCancel: (_) {
            // Resume animation if touch is cancelled
            controller.resumeAnimation();
          },
          child: RiveWidget(controller: controller, fit: Fit.fitWidth),
        ),
      ),
    );
  }
}
