import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/entities/chat_entity.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ChatConversation? _currentConversation;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isReloading = false;

  ChatProvider({ChatRepository? chatRepository})
      : _chatRepository = chatRepository ?? ChatRepository();

  // Getters
  ChatConversation? get currentConversation => _currentConversation;
  List<ChatConversation> get allConversations =>
      _chatRepository.getAllConversations();
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Create a new conversation
  Future<void> createNewConversation({String? title}) async {
    if (_auth.currentUser == null) {
      debugPrint('Cannot create conversation - no user logged in');
      return;
    }

    _currentConversation =
        await _chatRepository.createConversation(title: title);
    debugPrint(
        'Created new conversation: ${_currentConversation?.id}, title: ${_currentConversation?.title}');
    notifyListeners();
  }

  // Set current conversation
  void setCurrentConversation(String conversationId) {
    _currentConversation = _chatRepository.getConversationById(conversationId);
    debugPrint('Set current conversation: ${_currentConversation?.id}');
    notifyListeners();
  }

  // Send message
  Future<void> sendMessage(String messageText) async {
    if (_auth.currentUser == null) {
      debugPrint('Cannot send message - no user logged in');
      return;
    }

    if (_currentConversation == null) {
      debugPrint('No current conversation, cannot send message');
      return;
    }

    if (messageText.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Add user message to repository
      await _chatRepository.addUserMessage(
        _currentConversation!.id,
        messageText,
      );

      // Update conversation to include user message
      _currentConversation =
          _chatRepository.getConversationById(_currentConversation!.id);
      debugPrint(
          'Updated conversation with user message: ${_currentConversation!.messages.length}');

      // Add temporary loading message for assistant
      final loadingMessage = ChatMessage(
        text: '',
        role: MessageRole.assistant,
        isLoading: true,
      );
      _currentConversation!.messages.add(loadingMessage);
      debugPrint('Added temporary loading message for assistant');
      notifyListeners();

      // Send message to Gemini for assistant response
      await _chatRepository.sendMessageToGemini(
        _currentConversation!.id,
        messageText,
      );

      // Remove loading message
      _currentConversation!.messages.remove(loadingMessage);
      debugPrint('Removed temporary loading message');

      // Update conversation with final messages (user + assistant)
      _currentConversation =
          _chatRepository.getConversationById(_currentConversation!.id);
      debugPrint(
          'Updated conversation with final messages: ${_currentConversation!.messages.length}');
    } catch (e) {
      debugPrint('Error sending message: $e');
      // Remove loading message if added
      _currentConversation!.messages.removeWhere((msg) => msg.isLoading);
      _currentConversation!.messages.add(ChatMessage(
        text: 'Sorry, something went wrong. Please try again.',
        role: MessageRole.assistant,
        isLoading: false,
      ));
      debugPrint('Added error message due to failure');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('Loading state reset, isLoading: $_isLoading');
    }
  }

  // Initialize provider
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('ChatProvider already initialized');
      return;
    }

    debugPrint('Initializing ChatProvider');
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserConversations();
      } else {
        _currentConversation = null;
        _isInitialized = false;
        notifyListeners();
      }
    });

    // Initial load if user is logged in
    if (_auth.currentUser != null) {
      await _loadUserConversations();
    } else {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Load user conversations
  Future<void> _loadUserConversations() async {
    if (_isReloading) return;
    _isReloading = true;
    try {
      await _chatRepository.initialize(forceReload: true);
      final conversations = _chatRepository.getAllConversations();
      debugPrint('Loaded conversations: ${conversations.length}');

      if (conversations.isNotEmpty) {
        _currentConversation ??= conversations.first;
      } else {
        _currentConversation = null;
      }

      _isInitialized = true;
      notifyListeners();
    } finally {
      _isReloading = false;
    }
  }

  // Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    if (_auth.currentUser == null) {
      debugPrint('Cannot delete conversation - no user logged in');
      return;
    }

    debugPrint('Deleting conversation: $conversationId');
    await _chatRepository.deleteConversation(conversationId);
    final conversations = _chatRepository.getAllConversations();
    debugPrint('Conversations after deletion: ${conversations.length}');

    if (_currentConversation?.id == conversationId) {
      if (conversations.isNotEmpty) {
        _currentConversation = conversations.first;
        debugPrint('New current conversation: ${_currentConversation?.id}');
      } else {
        _currentConversation = null;
        debugPrint('No conversations left, current set to null');
      }
    }

    notifyListeners();
  }

  // Delete multiple conversations
  Future<void> deleteMultipleConversations(List<String> conversationIds) async {
    if (_auth.currentUser == null) {
      debugPrint('Cannot delete conversations - no user logged in');
      return;
    }

    debugPrint('Deleting conversations: $conversationIds');
    await _chatRepository.deleteMultipleConversations(conversationIds);
    await _chatRepository.forceReloadConversations();

    final conversations = _chatRepository.getAllConversations();
    debugPrint('Conversations after deletion: ${conversations.length}');

    if (conversationIds.contains(_currentConversation?.id)) {
      if (conversations.isNotEmpty) {
        _currentConversation = conversations.first;
        debugPrint('New current conversation: ${_currentConversation?.id}');
      } else {
        _currentConversation = null;
        debugPrint('No conversations left, current set to null');
      }
    }

    notifyListeners();
  }

  // Clear all conversations
  Future<void> clearAllConversations() async {
    if (_auth.currentUser == null) {
      debugPrint('Cannot clear conversations - no user logged in');
      return;
    }

    debugPrint('Clearing all conversations');
    await _chatRepository.clearAllConversations();
    _currentConversation = null;
    notifyListeners();
  }

  // Reload all conversations
  Future<void> reloadConversations() async {
    if (_auth.currentUser == null || _isReloading) {
      debugPrint(
          'Cannot reload conversations - no user logged in or already reloading');
      return;
    }

    _isReloading = true;
    try {
      await _chatRepository.forceReloadConversations();
      final conversations = _chatRepository.getAllConversations();
      debugPrint('Reloaded conversations: ${conversations.length}');

      if (_currentConversation != null) {
        final stillExists =
            conversations.any((c) => c.id == _currentConversation!.id);
        if (!stillExists && conversations.isNotEmpty) {
          _currentConversation = conversations.first;
        } else if (!stillExists) {
          _currentConversation = null;
        }
      } else if (conversations.isNotEmpty) {
        _currentConversation = conversations.first;
      }

      notifyListeners();
    } finally {
      _isReloading = false;
    }
  }
}
