class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
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

class ChatResponse {
  final String result;
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
      result: json['result'] as String,
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
