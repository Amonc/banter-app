import 'package:banter/create_account.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late File file;
  late PausableRiveController controller;
  bool isInitialized = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    initRive();
  }

  void initRive() async {
    file = (await File.asset(
      "assets/splash_screen.riv",
      riveFactory: Factory.rive,
    ))!;
    controller = PausableRiveController(file);
    final vmi = controller.dataBind(DataBind.auto());
    final click = vmi.trigger('trigger');

    // Listen for the trigger firing (caused by your Rive "Pointer Click" listener)
    click!.addListener((bool _) {
      // Will be called each time your Rive button is clicked
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateAccount()),
      );
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
          setState(() {
            isPaused = true;
            controller.pauseAnimation();
          });
        },
        onPointerUp: (_) {
          // Resume animation when releasing
          setState(() {
            isPaused = false;
            controller.resumeAnimation();
          });
        },
        onPointerCancel: (_) {
          // Resume animation if touch is cancelled
          setState(() {
            isPaused = false;
            controller.resumeAnimation();
          });
        },
        child: RiveWidget(controller: controller, fit: Fit.fitWidth),
      ),
    );
  }
}
