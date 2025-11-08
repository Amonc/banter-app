import 'package:banter/movie_screen.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:banter/model/chat_analysis_response.dart';

class BreakdownScreen extends StatefulWidget {
  final ChatAnalysisResponse analysisData;

  const BreakdownScreen({super.key, required this.analysisData});

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

    // Set values from actual analysis data
    final data = widget.analysisData;
    typoMachine?.value = getFirstName(data.loudestMember.name);
    mostSentCount?.value = 'SENT ${data.loudestMember.count} MESSAGES';
    mostSenderName?.value = getFirstName(data.loudestMember.name);
    groupChatName?.value = data.groupChatName;
    textsPerDay?.value = data.messageStats.avgMessagesPerDay.toStringAsFixed(1);
    totalMessageCount?.value = data.messageStats.totalMessages.toString();
    mostActiveDay?.value = data.messageStats.mostActiveDay;

    setState(() => isInitialized = true);

    

    // Switch to breakdown_2 after 5 seconds
    Future.delayed(const Duration(seconds: 30 ), () {
      switchToBreakdown2();
      Future.delayed(const Duration(seconds:48), (){
        Navigator.pushReplacement(context, PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                 MovieScreen(movieName: widget.analysisData.movieMatch.movie, redAlertName: widget.analysisData.redFlags.first.name,),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));
      });
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
      body: RiveWidget(controller: controller, fit: Fit.fitWidth),
    );
  }
}
