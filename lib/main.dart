import 'dart:convert';
import 'package:banter/breakdown_screen.dart';
import 'package:banter/model/chat_analysis_response.dart';
import 'package:banter/splash_screen.dart';
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

  runApp(MyApp(testData: testData));
}

class MyApp extends StatelessWidget {
  final ChatAnalysisResponse testData;

  const MyApp({super.key, required this.testData});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
