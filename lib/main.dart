import 'dart:convert';
import 'package:banter/model/chat_analysis_response.dart';
import 'package:banter/services/file_storage_service.dart';
import 'package:banter/splash_screen.dart';
import 'package:banter/turorial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "env/staging.env");
  await RiveNative.init();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load test data
  final testJsonString = await rootBundle.loadString('assets/test.json');
  final testData = ChatAnalysisResponse.fromJson(json.decode(testJsonString));

  // Check if onboarding (splash + create account) is complete
  final onboardingComplete = await FileStorageService.isOnboardingComplete();

  runApp(MyApp(testData: testData, onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final ChatAnalysisResponse testData;
  final bool onboardingComplete;

  const MyApp({super.key, required this.testData, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: onboardingComplete ? const TutorialPage() : SplashScreen(),
    );
  }
}
