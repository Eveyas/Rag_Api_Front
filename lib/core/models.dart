class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      content: json['content'],
    );
  }
}

class ChatRequest {
  final String message;
  final List<ChatMessage> history;

  ChatRequest({
    required this.message,
    this.history = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'history': history.map((msg) => msg.toJson()).toList(),
    };
  }
}

class ChatResponse {
  final String answer;

  ChatResponse({required this.answer});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      answer: json['answer'],
    );
  }
}