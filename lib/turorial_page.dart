import 'package:banter/create_account.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:file_picker/file_picker.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  late File file;
  late RiveWidgetController controller;
  bool isInitialized = false;

  ViewModelInstanceTrigger? _openExport;
  ViewModelInstanceTrigger? _uploadClick;
  ViewModelInstanceTrigger? _openCook;
  ViewModelInstanceTrigger? _openGetReady;

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
    _openExport = vmi.trigger('open_export');

    _uploadClick = vmi.trigger('upload_click');

    _openCook = vmi.trigger('open_cook');

    _openGetReady = vmi.trigger('open_get_ready');

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'txt'],
      allowMultiple: false,
    );

    // File selected, trigger cook animation and continue
    _openCook!.trigger();
    await Future.delayed(Duration(seconds: 5));
    _openGetReady!.trigger();
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
