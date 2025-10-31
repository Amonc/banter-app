import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class BreakdownScreen extends StatefulWidget {
  const BreakdownScreen({super.key});

  @override
  State<BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends State<BreakdownScreen> {
  late File file;
  late RiveWidgetController controller;
  bool isInitialized = false;
  bool showingBreakdown1 = false;

  @override
  void initState() {
    super.initState();
    initRive();
  }

  void initRive() async {
    file = (await File.asset(
      "assets/breakdown_1.riv",
      riveFactory: Factory.rive,
    ))!;
    controller = RiveWidgetController(file);
    final vmi = controller.dataBind(DataBind.auto());

    // Bind all the VMI strings for breakdown_1
    final typoMachine = vmi.string('typo_machine');
    final mostSentCount = vmi.string('most_sent_count');
    final mostSenderName = vmi.string('most_sender_name');
    final groupChatName = vmi.string('group_chat_name');
    final textsPerDay = vmi.string('texts_per_day');
    final totalMessageCount = vmi.string('total_message_count');
    final mostActiveDay = vmi.string('most_active_day');

    // Set example values (you can customize these or pass them as parameters)
    typoMachine?.value = 'John';
    mostSentCount?.value = 'SENT 1,234 MESSAGES';
    mostSenderName?.value = 'Alice';
    groupChatName?.value = 'Office Work';
    textsPerDay?.value = '420';
    totalMessageCount?.value = '15,678';
    mostActiveDay?.value = 'Friday';

    setState(() => isInitialized = true);

    

    // Switch to breakdown_2 after 5 seconds
    Future.delayed(const Duration(seconds: 30 ), () {
      switchToBreakdown2();
    });
  }

  void switchToBreakdown2() async {
    // Dispose old resources
    controller.dispose();
    file.dispose();

    // Load breakdown_2
    file = (await File.asset(
      "assets/breakdown_2.riv",
      riveFactory: Factory.rive,
    ))!;
    controller = RiveWidgetController(file);
    final vmi = controller.dataBind(DataBind.auto());

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

    // Set example values
    typoMachine?.value = 'John';
    redAlertName?.value = 'Bob';
    mostRepliesName?.value = 'Sarah';
    funniestUserName?.value = 'Mike';
    mostWordsUserName?.value = 'Emma';
    mostVocal4th?.value = 'Tom';
    mostVocal3rd?.value = 'Lisa';
    mostVocal2nd?.value = 'David';
    mostVocal1st?.value = 'Alice';


    setState(() => showingBreakdown1 = false);
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
      body: RiveWidget(controller: controller, fit: Fit.fitHeight),
    );
  }
}
