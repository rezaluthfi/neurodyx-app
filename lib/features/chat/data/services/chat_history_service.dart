import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat_entity.dart';

class ChatHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static const String _chatCollection = 'chats';
  static const String _conversationsSubcollection = 'conversations';

  // Get current user ID, return null if not logged in
  String? get _currentUserId => _auth.currentUser?.uid;

  // Load conversations from Firestore for current user
  Future<List<ChatConversation>> loadConversations() async {
    try {
      // Check if user is logged in
      final userId = _currentUserId;
      if (userId == null) {
        print('No user logged in - cannot load conversations');
        return [];
      }

      final conversationsSnapshot = await _firestore
          .collection(_chatCollection)
          .doc(userId)
          .collection(_conversationsSubcollection)
          .orderBy('updatedAt', descending: true)
          .get();

      return conversationsSnapshot.docs
          .map((doc) => ChatConversation.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading conversations from Firestore: $e');
      return [];
    }
  }

  // Save conversations to Firestore for current user
  Future<void> saveConversations(List<ChatConversation> conversations) async {
    try {
      // Check if user is logged in
      final userId = _currentUserId;
      if (userId == null) {
        print('No user logged in - cannot save conversations');
        throw Exception('User not authenticated');
      }

      // Get a batch write to make multiple writes atomic
      final batch = _firestore.batch();

      // Reference to the user's conversations collection
      final userConversationsRef = _firestore
          .collection(_chatCollection)
          .doc(userId)
          .collection(_conversationsSubcollection);

      // Add each conversation to the batch
      for (var conversation in conversations) {
        batch.set(
          userConversationsRef.doc(conversation.id),
          conversation.toJson(),
          SetOptions(merge: true),
        );
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error saving conversations to Firestore: $e');
      throw Exception('Failed to save conversations: $e');
    }
  }

  // Clear all saved conversations for current user
  Future<void> clearAllConversations() async {
    try {
      // Check if user is logged in
      final userId = _currentUserId;
      if (userId == null) {
        print('No user logged in - cannot clear conversations');
        throw Exception('User not authenticated');
      }

      // Get all conversation documents
      final conversationsSnapshot = await _firestore
          .collection(_chatCollection)
          .doc(userId)
          .collection(_conversationsSubcollection)
          .get();

      // Get a batch write to make multiple deletes atomic
      final batch = _firestore.batch();

      // Add each conversation document delete to the batch
      for (var doc in conversationsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error clearing conversations from Firestore: $e');
      throw Exception('Failed to clear conversations: $e');
    }
  }

  // Delete a single conversation for current user
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Check if user is logged in
      final userId = _currentUserId;
      if (userId == null) {
        print('No user logged in - cannot delete conversation');
        throw Exception('User not authenticated');
      }

      // Delete the conversation document
      await _firestore
          .collection(_chatCollection)
          .doc(userId)
          .collection(_conversationsSubcollection)
          .doc(conversationId)
          .delete();
    } catch (e) {
      print('Error deleting conversation from Firestore: $e');
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // Delete multiple conversations for current user
  Future<void> deleteMultipleConversations(List<String> conversationIds) async {
    try {
      // Check if user is logged in
      final userId = _currentUserId;
      if (userId == null) {
        print('No user logged in - cannot delete conversations');
        throw Exception('User not authenticated');
      }

      // Get a batch write to make multiple deletes atomic
      final batch = _firestore.batch();

      // Reference to the user's conversations collection
      final userConversationsRef = _firestore
          .collection(_chatCollection)
          .doc(userId)
          .collection(_conversationsSubcollection);

      // Add each conversation delete to the batch
      for (var conversationId in conversationIds) {
        batch.delete(userConversationsRef.doc(conversationId));
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error deleting multiple conversations from Firestore: $e');
      throw Exception('Failed to delete conversations: $e');
    }
  }

  // Method to save a single conversation (more efficient than saving all)
  Future<void> saveConversation(ChatConversation conversation) async {
    try {
      // Check if user is logged in
      final userId = _currentUserId;
      if (userId == null) {
        print('No user logged in - cannot save conversation');
        throw Exception('User not authenticated');
      }

      // Save the conversation document
      await _firestore
          .collection(_chatCollection)
          .doc(userId)
          .collection(_conversationsSubcollection)
          .doc(conversation.id)
          .set(conversation.toJson());
    } catch (e) {
      print('Error saving conversation to Firestore: $e');
      throw Exception('Failed to save conversation: $e');
    }
  }
}
