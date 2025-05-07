enum MessageRole { user, assistant }

class ChatMessage {
  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.role,
    DateTime? timestamp,
    this.isLoading = false,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to Gemini format
  Map<String, dynamic> toGeminiFormat() {
    return {
      'content': text,
    };
  }

  // From JSON for persistence
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isLoading: json['isLoading'] ?? false,
    );
  }

  // To JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'role': role == MessageRole.user ? 'user' : 'assistant',
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
    };
  }
}

class ChatConversation {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime updatedAt;

  ChatConversation({
    required this.id,
    required this.title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert conversation to Gemini format
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Conversation',
      messages: (json['messages'] as List?)
              ?.map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // To JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Update timestamp
  void updateTimestamp() {
    updatedAt = DateTime.now();
  }
}
