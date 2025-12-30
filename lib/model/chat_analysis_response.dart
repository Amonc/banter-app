class ChatAnalysisResponse {
  final MessageStats messageStats;
  final LoudestMember loudestMember;
  final List<TopEmoji> topEmojis;
  final List<Personality> personalities;
  final List<TopContributor> topContributors;
  final MostWords mostWords;
  final FunniestMember funniestMember;
  final MostReplies mostReplies;
  final List<RedFlag> redFlags;
  final MovieMatch movieMatch;
  final String? customAnalysis;
  final String groupChatName;
  final double responseTimeSeconds;
  final TokenUsage tokenUsage;

  ChatAnalysisResponse({
    required this.messageStats,
    required this.loudestMember,
    required this.topEmojis,
    required this.personalities,
    required this.topContributors,
    required this.mostWords,
    required this.funniestMember,
    required this.mostReplies,
    required this.redFlags,
    required this.movieMatch,
    this.customAnalysis,
    required this.groupChatName,
    required this.responseTimeSeconds,
    required this.tokenUsage,
  });

  factory ChatAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return ChatAnalysisResponse(
      messageStats: MessageStats.fromJson(json['message_stats']),
      loudestMember: LoudestMember.fromJson(json['loudest_member']),
      topEmojis: (json['top_emojis'] as List)
          .map((e) => TopEmoji.fromJson(e))
          .toList(),
      personalities: (json['personalities'] as List)
          .map((e) => Personality.fromJson(e))
          .toList(),
      topContributors: (json['top_contributors'] as List)
          .map((e) => TopContributor.fromJson(e))
          .toList(),
      mostWords: MostWords.fromJson(json['most_words']),
      funniestMember: FunniestMember.fromJson(json['funniest_member']),
      mostReplies: MostReplies.fromJson(json['most_replies']),
      redFlags: (json['red_flags'] as List)
          .map((e) => RedFlag.fromJson(e))
          .toList(),
      movieMatch: MovieMatch.fromJson(json['movie_match']),
      customAnalysis: json['custom_analysis'],
      groupChatName: json['group_chat_name'] ?? "",
      responseTimeSeconds: (json['response_time_seconds'] as num).toDouble(),
      tokenUsage: TokenUsage.fromJson(json['token_usage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_stats': messageStats.toJson(),
      'loudest_member': loudestMember.toJson(),
      'top_emojis': topEmojis.map((e) => e.toJson()).toList(),
      'personalities': personalities.map((e) => e.toJson()).toList(),
      'top_contributors': topContributors.map((e) => e.toJson()).toList(),
      'most_words': mostWords.toJson(),
      'funniest_member': funniestMember.toJson(),
      'most_replies': mostReplies.toJson(),
      'red_flags': redFlags.map((e) => e.toJson()).toList(),
      'movie_match': movieMatch.toJson(),
      'custom_analysis': customAnalysis,
      'group_chat_name': groupChatName,
      'response_time_seconds': responseTimeSeconds,
      'token_usage': tokenUsage.toJson(),
    };
  }
}

class MessageStats {
  final int totalMessages;
  final double avgMessagesPerDay;
  final String mostActiveDay;

  MessageStats({
    required this.totalMessages,
    required this.avgMessagesPerDay,
    required this.mostActiveDay,
  });

  factory MessageStats.fromJson(Map<String, dynamic> json) {
    return MessageStats(
      totalMessages: json['total_messages'],
      avgMessagesPerDay: (json['avg_messages_per_day'] as num).toDouble(),
      mostActiveDay: json['most_active_day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_messages': totalMessages,
      'avg_messages_per_day': avgMessagesPerDay,
      'most_active_day': mostActiveDay,
    };
  }
}

class LoudestMember {
  final String name;
  final int count;
  final dynamic details;

  LoudestMember({required this.name, required this.count, this.details});

  factory LoudestMember.fromJson(Map<String, dynamic> json) {
    return LoudestMember(
      name: json['name'],
      count: json['count'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'count': count, 'details': details};
  }
}

class TopEmoji {
  final String emoji;
  final int count;

  TopEmoji({required this.emoji, required this.count});

  factory TopEmoji.fromJson(Map<String, dynamic> json) {
    return TopEmoji(emoji: json['emoji'], count: json['count']);
  }

  Map<String, dynamic> toJson() {
    return {'emoji': emoji, 'count': count};
  }
}

class Personality {
  final String name;
  final String personalityType;
  final String description;

  Personality({
    required this.name,
    required this.personalityType,
    required this.description,
  });

  factory Personality.fromJson(Map<String, dynamic> json) {
    return Personality(
      name: json['name'],
      personalityType: json['personality_type'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'personality_type': personalityType,
      'description': description,
    };
  }
}

class TopContributor {
  final String name;
  final int count;
  final dynamic details;

  TopContributor({required this.name, required this.count, this.details});

  factory TopContributor.fromJson(Map<String, dynamic> json) {
    return TopContributor(
      name: json['name'],
      count: json['count'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'count': count, 'details': details};
  }
}

class MostWords {
  final String name;
  final int count;
  final dynamic details;

  MostWords({required this.name, required this.count, this.details});

  factory MostWords.fromJson(Map<String, dynamic> json) {
    return MostWords(
      name: json['name'],
      count: json['count'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'count': count, 'details': details};
  }
}

class FunniestMember {
  final String name;
  final int count;
  final dynamic details;

  FunniestMember({required this.name, required this.count, this.details});

  factory FunniestMember.fromJson(Map<String, dynamic> json) {
    return FunniestMember(
      name: json['name'],
      count: json['count'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'count': count, 'details': details};
  }
}

class MostReplies {
  final String name;
  final int count;
  final dynamic details;

  MostReplies({required this.name, required this.count, this.details});

  factory MostReplies.fromJson(Map<String, dynamic> json) {
    return MostReplies(
      name: json['name'],
      count: json['count'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'count': count, 'details': details};
  }
}

class RedFlag {
  final String name;
  final String personalityType;
  final String description;

  RedFlag({
    required this.name,
    required this.personalityType,
    required this.description,
  });

  factory RedFlag.fromJson(Map<String, dynamic> json) {
    return RedFlag(
      name: json['name'],
      personalityType: json['personality_type'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'personality_type': personalityType,
      'description': description,
    };
  }
}

class MovieMatch {
  final String movie;
  final String reason;

  MovieMatch({required this.movie, required this.reason});

  factory MovieMatch.fromJson(Map<String, dynamic> json) {
    return MovieMatch(movie: json['movie'], reason: json['reason']);
  }

  Map<String, dynamic> toJson() {
    return {'movie': movie, 'reason': reason};
  }
}

class TokenUsage {
  final int inputTokens;
  final int outputTokens;

  TokenUsage({required this.inputTokens, required this.outputTokens});

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      inputTokens: json['input_tokens'],
      outputTokens: json['output_tokens'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'input_tokens': inputTokens, 'output_tokens': outputTokens};
  }
}
