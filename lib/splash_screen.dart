import 'package:banter/create_account.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late File file;
  late RiveWidgetController controller;
  bool isInitialized = false;

  ViewModelInstanceTrigger? _onClick;
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
    controller = RiveWidgetController(file);
    final vmi = controller.dataBind(DataBind.auto());
    final click = vmi.trigger('trigger');

    _onClick = click;

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
      body: RiveWidget(controller: controller, fit: Fit.cover),
    );
  }
}
