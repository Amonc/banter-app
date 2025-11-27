import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:banter/model/chat_analysis_response.dart';
import 'package:banter/chat_screen.dart';

/// Enum to track which breakdown is currently active
enum BreakdownState {
  breakdown1,
  breakdown2,
  breakdown4,
  breakdown5,
  breakdown6,
  breakdown7,
  breakdown8,
  breakdown9,
  breakdown10,
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
  final bool showlastImmediately;

  const BreakdownScreen({
    super.key,
    required this.analysisData,
    this.showlastImmediately = false,
  });

  @override
  State<BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends State<BreakdownScreen> {
  late File file;
  late PausableRiveController controller;
  bool isInitialized = false;

  // Track active breakdown state
  BreakdownState _currentBreakdown = BreakdownState.breakdown1;

  // Trigger references for breakdown_1_to_4.riv
  ViewModelInstanceTrigger? _breakdown1Trigger;
  ViewModelInstanceTrigger? _breakdown2Trigger;
  ViewModelInstanceTrigger? _breakdown4Trigger;

  // Trigger references for breakdown_5_to_9.riv
  ViewModelInstanceTrigger? _breakdown5Trigger;
  ViewModelInstanceTrigger? _breakdown6Trigger;
  ViewModelInstanceTrigger? _breakdown7Trigger;
  ViewModelInstanceTrigger? _breakdown8Trigger;
  ViewModelInstanceTrigger? _breakdown9Trigger;

  // Trigger references for breakdown_10.riv (movie screen)
  ViewModelInstanceTrigger? _movieLoadingTrigger;
  ViewModelInstanceTrigger? _movieTheHangoverTrigger;
  ViewModelInstanceTrigger? _movieTheHungerGamesTrigger;
  ViewModelInstanceTrigger? _movieTheDevilWearsPradaTrigger;
  ViewModelInstanceTrigger? _movieMeanGirlsTrigger;
  ViewModelInstanceTrigger? _movieTheBreakfastClubTrigger;
  ViewModelInstanceTrigger? _movieWolfOfWallStreetTrigger;
  ViewModelInstanceTrigger? _movieMoneyballTrigger;
  ViewModelInstanceTrigger? _movieNapoleonDynamiteTrigger;
  ViewModelInstanceTrigger? _movieInsideOutTrigger;
  ViewModelInstanceTrigger? _movieProjectXTrigger;

  // Map of movie names to their trigger functions
  Map<String, ViewModelInstanceTrigger?> _movieTriggers = {};

  // Track which Rive file is currently loaded (0 = breakdown_1_to_4, 1 = breakdown_5_to_9, 2 = breakdown_10)
  int _currentRiveFile = 0;

  // Track press duration to distinguish tap from hold
  DateTime? _pressStartTime;
  static const _tapThreshold = Duration(milliseconds: 200);

  // Timer for auto-advancing from breakdown_9 to breakdown_10
  Timer? _breakdown9Timer;


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
        // Transition to breakdown_5_to_9.riv
        _loadBreakdown2File();
        break;
      case BreakdownState.breakdown5:
        _breakdown6Trigger?.trigger();
        break;
      case BreakdownState.breakdown6:
        _breakdown7Trigger?.trigger();
        break;
      case BreakdownState.breakdown7:
        _breakdown8Trigger?.trigger();
        break;
      case BreakdownState.breakdown8:
        _breakdown9Trigger?.trigger();
        break;
      case BreakdownState.breakdown9:
        // Cancel auto-advance timer since user manually navigated
        _breakdown9Timer?.cancel();
        // Transition to breakdown_10.riv (movie screen)
        _loadBreakdown10File();
        break;
      case BreakdownState.breakdown10:
        // Navigate to chat screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;
    }
  }

  void _goToPrevious() {
    print(_currentBreakdown);
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
      case BreakdownState.breakdown5:
        // Transition back to breakdown_1_to_4.riv and show breakdown_4
        _loadBreakdown1File(goToBreakdown4: true);
        break;
      case BreakdownState.breakdown6:
        _breakdown5Trigger?.trigger();
        break;
      case BreakdownState.breakdown7:
        _breakdown6Trigger?.trigger();
        break;
      case BreakdownState.breakdown8:
        _breakdown7Trigger?.trigger();
        break;
      case BreakdownState.breakdown9:
        // Cancel auto-advance timer since user manually navigated back
        _breakdown9Timer?.cancel();
        _breakdown8Trigger?.trigger();
        break;
      case BreakdownState.breakdown10:
        // Transition back to breakdown_5_to_9.riv and show breakdown_9
        _loadBreakdown2File(goToBreakdown9: true);
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
    _loadBreakdown1File();
  }

  void _loadBreakdown1File({bool goToBreakdown4 = false}) async {
    setState(() => isInitialized = false);

    // Dispose existing resources if they exist
    if (_currentRiveFile != 0) {
      controller.dispose();
      file.dispose();
    }

    file = (await File.asset(
      "assets/breakdown_1_to_4.riv",
      riveFactory: Factory.rive,
    ))!;
    controller = PausableRiveController(file);
    final vmi = controller.dataBind(DataBind.auto());

    // Get trigger references for breakdown_1_to_4.riv
    _breakdown1Trigger = vmi.trigger('breakdown_1_enter');
    _breakdown2Trigger = vmi.trigger('breakdown_2_enter');
    _breakdown4Trigger = vmi.trigger('breakdown_4_enter');

    // Set showLastImmediately to skip to breakdown_4 when going back from breakdown_5
    final showLastImmediately = vmi.boolean('showLastImmediately');
    if (goToBreakdown4) {
      showLastImmediately?.value = true;
    }

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
          // Reset showLastImmediately so going back from breakdown_2 shows breakdown_1
          showLastImmediately?.value = false;
          break;
      }
    });

    _currentRiveFile = 0;
    setState(() => isInitialized = true);

    // Trigger the appropriate breakdown based on context
    if (goToBreakdown4) {
      // Coming back from breakdown_5
      _breakdown4Trigger?.trigger();
    } else if (_currentBreakdown == BreakdownState.breakdown1) {
      // Initial load
      _breakdown1Trigger?.trigger();
    }
  }

  void _loadBreakdown2File({bool goToBreakdown9 = false}) async {
    setState(() => isInitialized = false);

    // Dispose existing resources
    controller.dispose();
    file.dispose();

    file = (await File.asset(
      "assets/breakdown_5_to_9.riv",
      riveFactory: Factory.rive,
    ))!;
    controller = PausableRiveController(file);
    final vmi = controller.dataBind(DataBind.auto());

    // Get trigger references for breakdown_5_to_9.riv
    _breakdown5Trigger = vmi.trigger('breakdown_5_enter');
    _breakdown6Trigger = vmi.trigger('breakdown_6_enter');
    _breakdown7Trigger = vmi.trigger('breakdown_7_enter');
    _breakdown8Trigger = vmi.trigger('breakdown_8_enter');
    _breakdown9Trigger = vmi.trigger('breakdown_9_enter');

    // Set showLastImmediately to skip to breakdown_9 when going back from breakdown_10
    final showLastImmediately = vmi.boolean('showLastImmediately');
    if (goToBreakdown9) {
      showLastImmediately?.value = true;
    }

    // Bind all the VMI strings for breakdown_2
    final typoMachine = vmi.string('typo_machine');
    final redAlertName = vmi.string('red_alert_name');
    final mostRepliesName = vmi.string('most_replies_name');
    final funniestUserName = vmi.string('funniest_user_name');
    final mostWordsUserName = vmi.string('most_words_user_name');
    final mostVocal4th = vmi.string('most_vocal_4th');
    final mostVocal3rd = vmi.string('most_vocal_3rd');
    final mostVocal2nd = vmi.string('most_vocal_2nd');
    final mostVocal1st = vmi.string('most_vocal_1st');

    // Set values from actual analysis data
    final data = widget.analysisData;
    typoMachine?.value = getFirstName(data.loudestMember.name);
    redAlertName?.value = data.redFlags.isNotEmpty ? getFirstName(data.redFlags.first.name) : 'N/A';
    mostRepliesName?.value = getFirstName(data.mostReplies.name);
    funniestUserName?.value = getFirstName(data.funniestMember.name);
    mostWordsUserName?.value = getFirstName(data.mostWords.name);

    // Sort top contributors by count (descending order)
    final sortedContributors = List.from(data.topContributors)
      ..sort((a, b) => b.count.compareTo(a.count));

    // Set top contributors (most vocal)
    if (sortedContributors.length > 3) {
      mostVocal4th?.value = getFirstName(sortedContributors[3].name);
    }
    if (sortedContributors.length > 2) {
      mostVocal3rd?.value = getFirstName(sortedContributors[2].name);
    }
    if (sortedContributors.length > 1) {
      mostVocal2nd?.value = getFirstName(sortedContributors[1].name);
    }
    if (sortedContributors.isNotEmpty) {
      mostVocal1st?.value = getFirstName(sortedContributors[0].name);
    }

    // Listen for state machine state changes
    controller.stateMachine.addEventListener((event) {
      print('State changed: ${event.name}');

      // Update the current breakdown based on the state name
      switch (event.name) {
        case 'breakdown_5':
          if (_currentBreakdown != BreakdownState.breakdown5) {
            setState(() => _currentBreakdown = BreakdownState.breakdown5);
          }
          break;
        case 'breakdown_6':
          if (_currentBreakdown != BreakdownState.breakdown6) {
            setState(() => _currentBreakdown = BreakdownState.breakdown6);
          }
          break;
        case 'breakdown_7':
          if (_currentBreakdown != BreakdownState.breakdown7) {
            setState(() => _currentBreakdown = BreakdownState.breakdown7);
          }
          break;
        case 'breakdown_8':
          if (_currentBreakdown != BreakdownState.breakdown8) {
            setState(() => _currentBreakdown = BreakdownState.breakdown8);
          }
          break;
        case 'breakdown_9':
          if (_currentBreakdown != BreakdownState.breakdown9) {
            setState(() => _currentBreakdown = BreakdownState.breakdown9);
          }
          // Reset showLastImmediately so going back from breakdown_6 shows breakdown_5
          showLastImmediately?.value = false;
          // Start auto-advance timer to breakdown_10 after 6 seconds
          _breakdown9Timer?.cancel();
          _breakdown9Timer = Timer(const Duration(seconds: 6), () {
            if (mounted && _currentBreakdown == BreakdownState.breakdown9) {
              _loadBreakdown10File();
            }
          });
          break;
      }
    });

    _currentRiveFile = 1;
    setState(() => isInitialized = true);

    // Trigger the appropriate breakdown based on context
    if (goToBreakdown9) {
      // Coming back from breakdown_10 - set state immediately
      setState(() => _currentBreakdown = BreakdownState.breakdown9);
      _breakdown9Trigger?.trigger();
    } else {
      // Trigger breakdown_5 to start the animation sequence
      _breakdown5Trigger?.trigger();
    }
  }

  void _loadBreakdown10File() async {
    setState(() => isInitialized = false);

    // Dispose existing resources
    controller.dispose();
    file.dispose();

    file = (await File.asset(
      "assets/breakdown_10.riv",
      riveFactory: Factory.rive,
    ))!;
    controller = PausableRiveController(file);
    final vmi = controller.dataBind(DataBind.auto());

    // Initialize all movie triggers
    _movieLoadingTrigger = vmi.trigger('movie_loading');
    _movieTheHangoverTrigger = vmi.trigger('movie_the hangover');
    _movieTheHungerGamesTrigger = vmi.trigger('movie_the_hunger_games');
    _movieTheDevilWearsPradaTrigger = vmi.trigger('movie_the_devil_wears_pra...');
    _movieMeanGirlsTrigger = vmi.trigger('movie_mean_girls');
    _movieTheBreakfastClubTrigger = vmi.trigger('movie_the_breakfast_club');
    _movieWolfOfWallStreetTrigger = vmi.trigger('movie_the_wolf_of_wall_str...');
    _movieMoneyballTrigger = vmi.trigger('movie_money_ball');
    _movieNapoleonDynamiteTrigger = vmi.trigger('movie_napolean_dynamite');
    _movieInsideOutTrigger = vmi.trigger('movie_inside_out');
    _movieProjectXTrigger = vmi.trigger('movie_project_x');

    // Initialize red_alert_name string
    final redAlertName = vmi.string('red_alert_name');
    final data = widget.analysisData;
    redAlertName?.value = data.redFlags.isNotEmpty ? getFirstName(data.redFlags.first.name) : 'N/A';

    // Create mapping
    _movieTriggers = {
      'The Hangover': _movieTheHangoverTrigger,
      'The Hunger Games': _movieTheHungerGamesTrigger,
      'The Devil Wears Prada': _movieTheDevilWearsPradaTrigger,
      'Mean Girls': _movieMeanGirlsTrigger,
      'Bridesmaids': _movieMeanGirlsTrigger,
      'The Breakfast Club': _movieTheBreakfastClubTrigger,
      'Wolf of Wall Street': _movieWolfOfWallStreetTrigger,
      'The Wolf of Wall Street': _movieWolfOfWallStreetTrigger,
      'Moneyball': _movieMoneyballTrigger,
      'Napoleon Dynamite': _movieNapoleonDynamiteTrigger,
      'Inside Out': _movieInsideOutTrigger,
      'Project X': _movieProjectXTrigger,
    };

    // Listen for state machine state changes
    controller.stateMachine.addEventListener((event) {
      print('State changed: ${event.name}');

      // Update to breakdown_10 state for any movie state
      if (_currentBreakdown != BreakdownState.breakdown10) {
        setState(() => _currentBreakdown = BreakdownState.breakdown10);
      }
    });

    _currentRiveFile = 2;
    setState(() {
      isInitialized = true;
      _currentBreakdown = BreakdownState.breakdown10;
    });

    // Trigger movie_loading first
    _movieLoadingTrigger?.trigger();

    // Wait 5 seconds then trigger the appropriate movie based on analysis data
    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      _triggerMovieFromResponse();
    }

    // Auto-navigate to chat screen after 6 more seconds (11 seconds total)
    await Future.delayed(const Duration(seconds: 6));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    }
  }

  void _triggerMovieFromResponse() {
    final movieName = widget.analysisData.movieMatch.movie;
    if (_movieTriggers.containsKey(movieName)) {
      _movieTriggers[movieName]?.trigger();
    }
  }


  @override
  void dispose() {
    _breakdown9Timer?.cancel();
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
      body: Listener(
        onPointerDown: (_) {
          // Track when press started
          _pressStartTime = DateTime.now();
          // Pause animation when touching the screen
          controller.pauseAnimation();
        },
        onPointerUp: (details) {
          // Resume animation when releasing
          controller.resumeAnimation();

          // Only trigger navigation if it was a quick tap, not a hold
          final pressDuration = DateTime.now().difference(_pressStartTime ?? DateTime.now());
          if (pressDuration < _tapThreshold) {
            final screenWidth = MediaQuery.of(context).size.width;
            final tapPosition = details.position.dx;

            // Instagram-style tap areas:
            // Left 1/3 of screen: go previous
            // Right 2/3 of screen: go next
            if (tapPosition < screenWidth / 3) {
              _goToPrevious();
            } else {
              _goToNext();
            }
          }
          _pressStartTime = null;
        },
        onPointerCancel: (_) {
          // Resume animation if touch is cancelled
          controller.resumeAnimation();
          _pressStartTime = null;
        },
        child: RiveWidget(controller: controller, fit: Fit.fitWidth),
      ),
    );
  }
}
