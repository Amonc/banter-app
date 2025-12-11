class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ChatResult? chatResult; // For AI responses with structured data

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.chatResult,
  });
}

class ChatRequest {
  final String query;
  final String? sessionId;
  final int sampleSize;

  ChatRequest({
    required this.query,
    this.sessionId,
    this.sampleSize = 200,
  });

  Map<String, String> toFormData() {
    final data = {
      'query': query,
      'sample_size': sampleSize.toString(),
    };

    if (sessionId != null) {
      data['session_id'] = sessionId!;
    }

    return data;
  }
}

class ChatResult {
  final String answer;
  final List<String> insights;
  final List<String> mentionedParticipants;
  final List<String> followUpQuestions;

  ChatResult({
    required this.answer,
    required this.insights,
    required this.mentionedParticipants,
    required this.followUpQuestions,
  });

  factory ChatResult.fromJson(Map<String, dynamic> json) {
    return ChatResult(
      answer: json['answer'] as String? ?? '',
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      mentionedParticipants: (json['mentioned_participants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      followUpQuestions: (json['follow_up_questions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class ChatResponse {
  final ChatResult result;
  final String sessionId;
  final String groupChatName;
  final double responseTimeSeconds;
  final TokenUsage tokenUsage;

  ChatResponse({
    required this.result,
    required this.sessionId,
    required this.groupChatName,
    required this.responseTimeSeconds,
    required this.tokenUsage,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      result: ChatResult.fromJson(json['result'] as Map<String, dynamic>),
      sessionId: json['session_id'] as String,
      groupChatName: json['group_chat_name'] as String,
      responseTimeSeconds: (json['response_time_seconds'] as num).toDouble(),
      tokenUsage: TokenUsage(
        inputTokens: json['token_usage']['input_tokens'] as int,
        outputTokens: json['token_usage']['output_tokens'] as int,
      ),
    );
  }
}

class TokenUsage {
  final int inputTokens;
  final int outputTokens;

  TokenUsage({
    required this.inputTokens,
    required this.outputTokens,
  });
}
