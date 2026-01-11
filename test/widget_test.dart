// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:banter/main.dart';
import 'package:banter/model/chat_analysis_response.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Create mock test data
    final testData = ChatAnalysisResponse(
      groupChatName: 'Test Group',
      messageStats: MessageStats(
        totalMessages: 100,
        avgMessagesPerDay: 10.0,
        mostActiveDay: 'Monday',
      ),
      loudestMember: LoudestMember(name: 'Test User', count: 50),
      mostReplies: MostReplies(name: 'Test User', count: 30),
      funniestMember: FunniestMember(name: 'Test User', count: 20),
      mostWords: MostWords(name: 'Test User', count: 1000),
      topContributors: [],
      topEmojis: [],
      personalities: [],
      redFlags: [],
      movieMatch: MovieMatch(movie: 'Test Movie', reason: 'Test reason'),
      responseTimeSeconds: 1.0,
      tokenUsage: TokenUsage(inputTokens: 100, outputTokens: 50),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      testData: testData,
      onboardingComplete: false,
    ));

    // Just verify the app builds without error
    await tester.pump();
  });
}
