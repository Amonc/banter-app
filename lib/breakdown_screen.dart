import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:banter/model/chat_analysis_response.dart';
import 'package:banter/chat_screen.dart';
import 'package:banter/services/audio_service.dart';

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

  // Red alert cycling state
  int _currentRedAlertIndex = 0;
  ViewModelInstanceTrigger? _nextRedAlertTrigger;

  ViewModelInstanceString? _redAlertName;
  ViewModelInstanceString? _redAlertPersonalityType;
  ViewModelInstanceString? _redAlertDescription;
  bool isNextPressed = true;

  ViewModelInstanceBoolean? _showRedAlertImmediately;

  // Track if movie is showing (vs loading) in breakdown_10
  bool _isMovieShowing = false;
  Timer? _movieAutoTriggerTimer;

  @override
  void initState() {
    super.initState();
    initRive();
    _playBoomSound();
  }

  void _playBoomSound() {
    AudioService().playBoomLoop();
  }

  void _goToNext() {
    isNextPressed = true;
    print(_currentBreakdown);
    isInitialized = true;
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
        final redFlags = widget.analysisData.redFlags;
        // If at last red alert or no red alerts, go to breakdown_10
        if (redFlags.isEmpty || _currentRedAlertIndex >= redFlags.length - 1) {
          _loadBreakdown10File();
        } else {
          // Cycle to next red alert

          _nextRedAlertTrigger?.trigger();
        }
        break;
      case BreakdownState.breakdown10:
        // Cancel auto-trigger timer on manual navigation
        _movieAutoTriggerTimer?.cancel();
        if (!_isMovieShowing) {
          // First tap: trigger movie by name
          _triggerMovieFromResponse();
          _isMovieShowing = true;
        } else {
          // Second tap: navigate to chat screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        }
        break;
    }
  }

  void _goToPrevious() {
    isNextPressed = false;
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
        // If at first red alert, go back to breakdown_8
        if (_currentRedAlertIndex <= 0) {
          // Reset to 0 so first red alert shows when coming forward again
          _currentRedAlertIndex = 0;
          _breakdown8Trigger?.trigger();
        } else {
          // Cycle to previous red alert - name change handled by event listener
          _nextRedAlertTrigger?.trigger();
        }
        break;
      case BreakdownState.breakdown10:
        // Cancel auto-trigger timer on manual navigation
        _movieAutoTriggerTimer?.cancel();
        _showRedAlertImmediately?.value = true;
        // Transition back to breakdown_5_to_9.riv and show breakdown_9
        _loadBreakdown2File(goToBreakdown9: true);
        _showRedAlertImmediately?.value = false;
        break;
    }
  }

  /// Extracts the first name from a full name
  /// e.g., "John Doe" -> "John", "~ Alice Smith" -> "Alice"
  String getName(String fullName) {
    // Remove leading special characters like ~, @, etc.
    String cleanName = fullName.trim().replaceAll(
      RegExp(r'^[~@#$%^&*]+\s*'),
      '',
    );

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
    typoMachine?.value = getName(data.loudestMember.name);
    mostSentCount?.value = 'SENT ${data.loudestMember.count} MESSAGES';
    mostSenderName?.value = getName(data.loudestMember.name);
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
    _nextRedAlertTrigger = vmi.trigger('next_red_alert');

    // Reset red alert cycling state - if coming back from breakdown_10, start at last red alert
    final redFlags = widget.analysisData.redFlags;
    if (goToBreakdown9 && redFlags.isNotEmpty) {
      _currentRedAlertIndex = redFlags.length - 1;
    } else {
      _currentRedAlertIndex = 0;
    }

    // Set showLastImmediately to skip to breakdown_9 when going back from breakdown_10
    final showLastImmediately = vmi.boolean('showLastImmediately');
    if (goToBreakdown9) {
      showLastImmediately?.value = true;
    }

    // Bind all the VMI strings for breakdown_2
    final typoMachine = vmi.string('typo_machine');
    _redAlertName = vmi.string('red_alert_name');
    _redAlertPersonalityType = vmi.string('red_alert_personality_type');
    _redAlertDescription = vmi.string('red_alert_description');
    _showRedAlertImmediately = vmi.boolean('show_last_immediately');
    final mostRepliesName = vmi.string('most_replies_name');
    final funniestUserName = vmi.string('funniest_user_name');
    final mostWordsUserName = vmi.string('most_words_user_name');
    final mostVocal4th = vmi.string('most_vocal_4th');
    final mostVocal3rd = vmi.string('most_vocal_3rd');
    final mostVocal2nd = vmi.string('most_vocal_2nd');
    final mostVocal1st = vmi.string('most_vocal_1st');

    // Set values from actual analysis data
    final data = widget.analysisData;
    typoMachine?.value = getName(data.loudestMember.name);
    _redAlertName?.value = redFlags.isNotEmpty
        ? getName(redFlags[_currentRedAlertIndex].name)
        : 'N/A';
    _redAlertPersonalityType?.value = redFlags.isNotEmpty
        ? redFlags[_currentRedAlertIndex].personalityType
        : 'N/A';
    _redAlertDescription?.value = redFlags.isNotEmpty
        ? redFlags[_currentRedAlertIndex].description
        : 'N/A';
    mostRepliesName?.value = getName(data.mostReplies.name);
    funniestUserName?.value = getName(data.funniestMember.name);
    mostWordsUserName?.value = getName(data.mostWords.name);
    _showRedAlertImmediately = vmi.boolean('showLastImmediately');
    // Sort top contributors by count (descending order)
    final sortedContributors = List.from(data.topContributors)
      ..sort((a, b) => b.count.compareTo(a.count));

    // Set top contributors (most vocal)
    if (sortedContributors.length > 3) {
      mostVocal4th?.value = getName(sortedContributors[3].name);
    }
    if (sortedContributors.length > 2) {
      mostVocal3rd?.value = getName(sortedContributors[2].name);
    }
    if (sortedContributors.length > 1) {
      mostVocal2nd?.value = getName(sortedContributors[1].name);
    }
    if (sortedContributors.isNotEmpty) {
      mostVocal1st?.value = getName(sortedContributors[0].name);
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
          // Ensure red alert data is set for current index when entering breakdown_9
          if (redFlags.isNotEmpty) {
            _redAlertName?.value = getName(redFlags[_currentRedAlertIndex].name);
            _redAlertPersonalityType?.value =
                redFlags[_currentRedAlertIndex].personalityType;
            _redAlertDescription?.value =
                redFlags[_currentRedAlertIndex].description;
          }
          break;
        case 'change_red_alert':
          if (isNextPressed) {
            if (_currentRedAlertIndex < redFlags.length - 1) {
              _currentRedAlertIndex++;
            } else {
              _loadBreakdown10File();
            }
          } else {
            if (_currentRedAlertIndex > 0) {
              if (_showRedAlertImmediately!.value == false) {
                _currentRedAlertIndex--;
              }

              _showRedAlertImmediately!.value = false;
            } else {
              // At first red alert going backward, go to breakdown_8
              _breakdown8Trigger?.trigger();
            }
          }

          _redAlertName?.value = getName(redFlags[_currentRedAlertIndex].name);
          _redAlertPersonalityType?.value =
              redFlags[_currentRedAlertIndex].personalityType;
          _redAlertDescription?.value =
              redFlags[_currentRedAlertIndex].description;
          isNextPressed = true;
          setState(() {});
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
    _showRedAlertImmediately!.value = true;
    _isMovieShowing = false; // Reset immediately before async operations
    _movieAutoTriggerTimer?.cancel(); // Cancel any existing timer
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
    _movieTheDevilWearsPradaTrigger = vmi.trigger(
      'movie_the_devil_wears_prada',
    );
    _movieMeanGirlsTrigger = vmi.trigger('movie_mean_girls');
    _movieTheBreakfastClubTrigger = vmi.trigger('movie_the_breakfast_club');
    _movieWolfOfWallStreetTrigger = vmi.trigger(
      'movie_the_wolf_of_wall_street',
    );
    _movieMoneyballTrigger = vmi.trigger('movie_money_ball');
    _movieNapoleonDynamiteTrigger = vmi.trigger('movie_napolean_dynamite');
    _movieInsideOutTrigger = vmi.trigger('movie_inside_out');
    _movieProjectXTrigger = vmi.trigger('movie_project_x');

    // Initialize red_alert strings for the last red flag
    final redAlertName = vmi.string('red_alert_name');
    final redAlertPersonalityType = vmi.string('red_alert_personality_type');
    final redAlertDescription = vmi.string('red_alert_description');
    final data = widget.analysisData;
    final lastRedFlag = data.redFlags.isNotEmpty ? data.redFlags.last : null;
    redAlertName?.value = lastRedFlag != null
        ? getName(lastRedFlag.name)
        : 'N/A';
    redAlertPersonalityType?.value = lastRedFlag?.personalityType ?? 'N/A';
    redAlertDescription?.value = lastRedFlag?.description ?? 'N/A';

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

    // // Listen for state machine state changes
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

    // Trigger movie_loading first (movie will be triggered on next tap or after 5 seconds)
    _movieLoadingTrigger?.trigger();

    // Auto-trigger movie after 5 seconds
    _movieAutoTriggerTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isMovieShowing) {
        _triggerMovieFromResponse();
        _isMovieShowing = true;
      }
    });

    // Auto-navigate to chat screen after 6 more seconds (11 seconds total)

    // if (mounted) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const ChatScreen()),
    //   );
    // }
  }

  void _triggerMovieFromResponse() {
    final movieMatch = widget.analysisData.movieMatch;
    print('Movie Data:');
    print('  Movie: ${movieMatch.movie}');
    print('  Reason: ${movieMatch.reason}');
    print('  Available triggers: ${_movieTriggers.keys.toList()}');
    print('  Trigger exists: ${_movieTriggers.containsKey(movieMatch.movie)}');
    print('  Trigger value: ${_movieTriggers[movieMatch.movie]}');
    print('  Devil Wears Prada trigger: $_movieTheDevilWearsPradaTrigger');

    if (_movieTriggers.containsKey(movieMatch.movie)) {
      print('  Triggering movie: ${movieMatch.movie}');
      _movieTriggers[movieMatch.movie]?.trigger();
      print('  Trigger fired!');
    }
  }

  @override
  void dispose() {
    _movieAutoTriggerTimer?.cancel();
    file.dispose();
    controller.dispose();
    super.dispose();
  }

  /// Calculate total number of dots
  /// Formula: 9 breakdowns + (redAlerts - 1) for additional red alerts
  int _getTotalDots() {
    final redFlagsCount = widget.analysisData.redFlags.length;
    return 9 + (redFlagsCount > 0 ? redFlagsCount - 1 : 0);
  }

  /// Get current dot index based on breakdown state
  int _getCurrentDotIndex() {
    switch (_currentBreakdown) {
      case BreakdownState.breakdown1:
        return 0;
      case BreakdownState.breakdown2:
        return 1;
      case BreakdownState.breakdown4:
        return 2;
      case BreakdownState.breakdown5:
        return 3;
      case BreakdownState.breakdown6:
        return 4;
      case BreakdownState.breakdown7:
        return 5;
      case BreakdownState.breakdown8:
        return 6;
      case BreakdownState.breakdown9:
        // Each red alert gets its own index starting at 7
        return 7 + _currentRedAlertIndex;
      case BreakdownState.breakdown10:
        return _getTotalDots() - 1;
    }
  }

  Widget _buildDotIndicator() {
    final totalDots = _getTotalDots();
    final currentIndex = _getCurrentDotIndex();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDots, (index) {
        final isActive = index == currentIndex;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
          ),
        );
      }),
    );
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
      body: Stack(
        children: [
          Listener(
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
              final pressDuration = DateTime.now().difference(
                _pressStartTime ?? DateTime.now(),
              );
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
          // Dot indicator - animates to bottom for breakdown4 and breakdown5
          Builder(
            builder: (context) {
              final isBottom =
                  _currentBreakdown == BreakdownState.breakdown4 ||
                  _currentBreakdown == BreakdownState.breakdown5;
              final screenHeight = MediaQuery.of(context).size.height;
              final topPadding = MediaQuery.of(context).padding.top;
              final bottomPadding = MediaQuery.of(context).padding.bottom;

              final topPosition = isBottom
                  ? screenHeight - bottomPadding - 48
                  : topPadding + 16;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: topPosition,
                left: 0,
                right: 0,
                child: Center(child: _buildDotIndicator()),
              );
            },
          ),
        ],
      ),
    );
  }
}
