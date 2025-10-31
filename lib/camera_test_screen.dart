import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class CameraTestScreen extends StatefulWidget {
  const CameraTestScreen({super.key});

  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen> {
  late File file;
  late RiveWidgetController controller;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    initRive();
  }

  void initRive() async {
    file = (await File.asset("assets/camera.riv", riveFactory: Factory.rive))!;
    controller = RiveWidgetController(file);
    final vmi = controller.dataBind(DataBind.auto());
    final groupChatName = vmi.string('textInput');
    groupChatName?.value = 'Hablu';
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
      body: RiveWidget(controller: controller, fit: Fit.contain),
    );
  }
}
