import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:banter/chat_screen.dart';

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

class MovieScreen extends StatefulWidget {
  final String movieName;
  final String redAlertName;

  const MovieScreen({
    super.key,
    required this.movieName,
    required this.redAlertName,
  });

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  late File file;
  late PausableRiveController controller;
  bool isInitialized = false;
  bool canNavigateToChat = false;

  ViewModelInstanceTrigger? _movieLoading;
  ViewModelInstanceTrigger? _movieTheHangover;
  ViewModelInstanceTrigger? _movieTheHungerGames;
  ViewModelInstanceTrigger? _movieTheDevilWearsPrada;
  ViewModelInstanceTrigger? _movieBridesmaids;
  ViewModelInstanceTrigger? _movieTheBreakfastClub;
  ViewModelInstanceTrigger? _movieWolfOfWallStreet;
  ViewModelInstanceTrigger? _movieMoneyball;
  ViewModelInstanceTrigger? _movieNapoleanDynamite;
  ViewModelInstanceTrigger? _movieInsideOut;
  ViewModelInstanceTrigger? _movieProjectX;

  ViewModelInstanceString? _redAlertName;

  // Map of movie names to their trigger functions
  Map<String, ViewModelInstanceTrigger?> movieTriggers = {};

  @override
  void initState() {
    super.initState();
    initRive();
  }

  void initRive() async {
    file = (await File.asset(
      "assets/breakdown_3.riv",
      riveFactory: Factory.rive,
    ))!;
    controller = PausableRiveController(file);
    final vmi = controller.dataBind(DataBind.auto());

    // Initialize all triggers
    _movieLoading = vmi.trigger('movie_loading');
    _movieTheHangover = vmi.trigger('movie_the hangover');
    _movieTheHungerGames = vmi.trigger('movie_the_hunger_games');
    _movieTheDevilWearsPrada = vmi.trigger('movie_the_devil_wears_pra...');
    _movieBridesmaids = vmi.trigger('movie_mean_girls'); // Note: screenshot shows mean_girls, but you mentioned Bridesmaids
    _movieTheBreakfastClub = vmi.trigger('movie_the_breakfast_club');
    _movieWolfOfWallStreet = vmi.trigger('movie_the_wolf_of_wall_str...');
    _movieMoneyball = vmi.trigger('movie_money_ball');
    _movieNapoleanDynamite = vmi.trigger('movie_napolean_dynamite');
    _movieInsideOut = vmi.trigger('movie_inside_out');
    _movieProjectX = vmi.trigger('movie_project_x');

    // Initialize red_alert_name string
    _redAlertName = vmi.string('red_alert_name');
    _redAlertName?.value = widget.redAlertName;

    // Create mapping
    movieTriggers = {
      'The Hangover': _movieTheHangover,
      'The Hunger Games': _movieTheHungerGames,
      'The Devil Wears Prada': _movieTheDevilWearsPrada,
      'Bridesmaids': _movieBridesmaids,
      'The Breakfast Club': _movieTheBreakfastClub,
      'Wolf of Wall Street': _movieWolfOfWallStreet,
      'Moneyball': _movieMoneyball,
      'Napoleon Dynamite': _movieNapoleanDynamite,
      'Inside Out': _movieInsideOut,
      'Project X': _movieProjectX,
    };

    setState(() => isInitialized = true);

    // Trigger movie_loading in initState
    _movieLoading?.trigger();

    // Wait 5 seconds then trigger the appropriate movie
    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      _triggerMovieFromResponse();
      // Enable navigation to chat after 5 seconds
      setState(() {
        canNavigateToChat = true;
      });
    }
    await Future.delayed(const Duration(seconds: 10));
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen()));
  }

  void _triggerMovieFromResponse() {
    // Trigger the movie based on the movieName parameter
    if (movieTriggers.containsKey(widget.movieName)) {
      movieTriggers[widget.movieName]?.trigger();
    }
  }

  @override
  void dispose() {
    file.dispose();
    controller.dispose();
    super.dispose();
  }

  void _navigateToChat() {
    if (canNavigateToChat) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatScreen(),
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
      body: Listener(
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
        child: GestureDetector(
          onDoubleTap: _navigateToChat,
          child: RiveWidget(controller: controller, fit: Fit.fitWidth),
        ),
      ),
    );
  }
}
