import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../services/chat_history_service.dart';
import '../services/gemini_api_service.dart';
import '../../domain/entities/chat_entity.dart';

class ChatRepository {
  final GeminiApiService _geminiApiService;
  final ChatHistoryService _historyService;
  List<ChatConversation> _conversations = [];
  final uuid = const Uuid();
  bool _isInitialized = false;

  ChatRepository({
    GeminiApiService? geminiApiService,
    ChatHistoryService? historyService,
  })  : _geminiApiService = geminiApiService ?? GeminiApiService(),
        _historyService = historyService ?? ChatHistoryService();

  // Create a new conversation
  Future<ChatConversation> createConversation({String? title}) async {
    final conversation = ChatConversation(
      id: uuid.v4(),
      title: title ?? 'New Conversation',
    );
    _conversations.add(conversation);
    await _historyService.saveConversation(conversation);
    debugPrint(
        'Created conversation: ${conversation.id}, title: ${conversation.title}');
    return conversation;
  }

  // Initialize repository and load saved conversations
  Future<void> initialize({bool forceReload = false}) async {
    if (!_isInitialized || forceReload) {
      try {
        _conversations = await _historyService.loadConversations();
        _isInitialized = true;
        debugPrint(
            'ChatRepository initialized with ${_conversations.length} conversations');
      } catch (e) {
        debugPrint('Error initializing chat repository: $e');
        _conversations = [];
        _isInitialized = true;
      }
    }
  }

  // Get all conversations
  List<ChatConversation> getAllConversations() {
    return _conversations;
  }

  // Get conversation by ID
  ChatConversation? getConversationById(String id) {
    try {
      return _conversations.firstWhere((conversation) => conversation.id == id);
    } catch (e) {
      debugPrint('Conversation with ID $id not found');
      return null;
    }
  }

  // Save a single conversation
  Future<void> saveConversation(ChatConversation conversation) async {
    try {
      await _historyService.saveConversation(conversation);
      debugPrint('Saved conversation: ${conversation.id}');
    } catch (e) {
      debugPrint('Error saving conversation: $e');
    }
  }

  // Save all conversations
  Future<void> saveConversations() async {
    try {
      await _historyService.saveConversations(_conversations);
      debugPrint('Conversations saved: ${_conversations.length}');
    } catch (e) {
      debugPrint('Error saving conversations: $e');
    }
  }

  // Add a message to a conversation
  Future<void> addMessageToConversation(
      String conversationId, ChatMessage message) async {
    final conversation = getConversationById(conversationId);
    if (conversation != null) {
      conversation.messages.add(message);
      conversation.updateTimestamp();
      await _historyService.saveConversation(conversation);
    } else {
      debugPrint('Cannot add message - conversation $conversationId not found');
    }
  }

  // Add user message and save conversation
  Future<void> addUserMessage(String conversationId, String messageText) async {
    final conversation = getConversationById(conversationId);
    if (conversation == null) {
      throw Exception('Conversation not found');
    }

    debugPrint('Adding user message to conversation: "$messageText"');
    final userMessage = ChatMessage(
      text: messageText,
      role: MessageRole.user,
    );
    conversation.messages.add(userMessage);
    conversation.updateTimestamp();
    await _historyService.saveConversation(conversation);
    debugPrint('Added user message: ${userMessage.text}');
  }

  // Send message to Gemini API and get response
  Future<void> sendMessageToGemini(
      String conversationId, String messageText) async {
    final conversation = getConversationById(conversationId);
    if (conversation == null) {
      throw Exception('Conversation not found');
    }

    try {
      // Prepare history for Gemini API
      final nonLoadingMessages =
          conversation.messages.where((msg) => !msg.isLoading).toList();
      final recentMessages = nonLoadingMessages.length > 5
          ? nonLoadingMessages.sublist(nonLoadingMessages.length - 5)
          : nonLoadingMessages;

      List<Map<String, dynamic>> history = [];
      for (var msg in recentMessages) {
        history.add({
          'role': msg.role == MessageRole.user ? 'user' : 'model',
          'content': msg.text,
        });
      }

      debugPrint('Sending message with history: $history');

      // Call Gemini API
      final response = await _geminiApiService.sendMessage(
        messageText,
        history: history,
      );

      debugPrint('Received response from Gemini API');

      // Extract response text
      final responseText = _geminiApiService.extractResponseText(response);
      debugPrint('Extracted text: $responseText');

      // Add assistant message
      final assistantMessage = ChatMessage(
        text: responseText,
        role: MessageRole.assistant,
      );
      conversation.messages.add(assistantMessage);
      conversation.updateTimestamp();
      await _historyService.saveConversation(conversation);
      debugPrint('Added assistant message: $responseText');
    } catch (e) {
      debugPrint('Error during Gemini API call: $e');
      final errorMessage = ChatMessage(
        text: 'Sorry, I couldn\'t process your message. Please try again.',
        role: MessageRole.assistant,
      );
      conversation.messages.add(errorMessage);
      conversation.updateTimestamp();
      await _historyService.saveConversation(conversation);
      debugPrint('Added error message due to failure');
      throw e;
    }
  }

  // Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      _conversations
          .removeWhere((conversation) => conversation.id == conversationId);
      await _historyService.deleteConversation(conversationId);
      debugPrint('Conversation $conversationId deleted');
    } catch (e) {
      debugPrint('Error deleting conversation: $e');
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // Delete multiple conversations
  Future<void> deleteMultipleConversations(List<String> conversationIds) async {
    try {
      _conversations.removeWhere(
          (conversation) => conversationIds.contains(conversation.id));
      await _historyService.deleteMultipleConversations(conversationIds);
      debugPrint('Deleted ${conversationIds.length} conversations');
    } catch (e) {
      debugPrint('Error deleting multiple conversations: $e');
      throw Exception('Failed to delete conversations: $e');
    }
  }

  // Clear all conversations
  Future<void> clearAllConversations() async {
    try {
      await _historyService.clearAllConversations();
      _conversations.clear();
      debugPrint('All conversations cleared');
    } catch (e) {
      debugPrint('Error clearing all conversations: $e');
      throw Exception('Failed to clear conversations: $e');
    }
  }

  // Force reload conversations from Firestore
  Future<void> forceReloadConversations() async {
    _isInitialized = false;
    await initialize(forceReload: true);
  }
}
