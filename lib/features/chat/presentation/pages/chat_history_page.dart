import 'package:flutter/material.dart';
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';
import 'package:neurodyx/features/main/presentation/pages/main_navigator.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/chat_entity.dart';
import '../providers/chat_provider.dart';
import 'chat_page.dart';

class ChatHistoryPage extends StatefulWidget {
  final int sourceTabIndex;

  const ChatHistoryPage({
    super.key,
    this.sourceTabIndex = 0,
  });

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _isSelectionMode = false;
  final Set<String> _selectedConversationIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    debugPrint(
        'ChatHistoryPage initialized with sourceTabIndex: ${widget.sourceTabIndex}, isSelectionMode: $_isSelectionMode');
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedConversationIds.clear();
      }
      debugPrint('Selection mode toggled: $_isSelectionMode');
    });
  }

  void _toggleSelection(String conversationId) {
    setState(() {
      if (_selectedConversationIds.contains(conversationId)) {
        _selectedConversationIds.remove(conversationId);
        debugPrint('Deselected conversation: $conversationId');
      } else {
        _selectedConversationIds.add(conversationId);
        debugPrint('Selected conversation: $conversationId');
      }
      debugPrint('Selected conversations: ${_selectedConversationIds.length}');
    });
  }

  Future<void> _deleteSelectedConversations() async {
    if (_selectedConversationIds.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'Please select at least one conversation to delete',
        type: SnackBarType.error,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Selected Conversations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
            'Are you sure you want to delete ${_selectedConversationIds.length} selected conversation${_selectedConversationIds.length > 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final chatProvider = context.read<ChatProvider>();
      await chatProvider
          .deleteMultipleConversations(_selectedConversationIds.toList());
      if (mounted) {
        debugPrint(
            'After deletion, conversations: ${chatProvider.allConversations.length}');
        CustomSnackBar.show(
          context,
          message:
              '${_selectedConversationIds.length} conversation${_selectedConversationIds.length > 1 ? 's' : ''} deleted',
          type: SnackBarType.success,
        );
        setState(() {
          _selectedConversationIds.clear();
          _isSelectionMode = false;
          _searchText = '';
        });
      }
    }
  }

  Future<void> _showClearAllConfirmDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Clear All Conversations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
            'Are you sure you want to delete all conversations? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.clearAllConversations();
      if (mounted) {
        debugPrint(
            'After clearing all, conversations: ${chatProvider.allConversations.length}');
        CustomSnackBar.show(
          context,
          message: 'All conversations cleared',
          type: SnackBarType.success,
        );
        setState(() {
          _selectedConversationIds.clear();
          _isSelectionMode = false;
        });
      }
    }
  }

  String _getConversationPreview(ChatConversation conversation) {
    if (conversation.messages.isEmpty) {
      return 'No messages yet';
    }

    final lastMessage = conversation.messages.last;
    final previewText = lastMessage.text.trim();

    if (previewText.length > 50) {
      return '${previewText.substring(0, 47)}...';
    }

    return previewText;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final conversationDate = DateTime(date.year, date.month, date.day);

    if (conversationDate == today) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (conversationDate == yesterday) {
      return 'Yesterday, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  // Improved helper method for back navigation
  void _handleBackToMainNavigator(BuildContext context) {
    debugPrint(
        'ChatHistoryPage back to MainNavigator triggered with tab: ${widget.sourceTabIndex}');

    // Ensure we're respecting the original source tab that was passed to this page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MainNavigator(
          initialIndex: widget.sourceTabIndex,
        ),
      ),
      (route) =>
          false, // Clear existing routes from stack to prevent back button issues
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Handle back behavior manually for consistency
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Use helper method for consistent navigation behavior
        _handleBackToMainNavigator(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isSelectionMode
                ? '${_selectedConversationIds.length} Selected'
                : 'Chat History',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackToMainNavigator(context),
            tooltip: 'Back',
          ),
          actions: [
            if (_isSelectionMode)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteSelectedConversations,
                tooltip: 'Delete Selected',
              ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'clear_all') {
                  _showClearAllConfirmDialog();
                } else if (value == 'select_mode') {
                  _toggleSelectionMode();
                }
              },
              itemBuilder: (context) => [
                if (!_isSelectionMode)
                  const PopupMenuItem<String>(
                    value: 'select_mode',
                    child: Text('Select Mode'),
                  ),
                const PopupMenuItem<String>(
                  value: 'clear_all',
                  child: Text('Clear All Conversations'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  final conversations = chatProvider.allConversations;
                  debugPrint('Conversations loaded: ${conversations.length}');

                  if (conversations.isEmpty) {
                    debugPrint('Showing no conversations message');
                    return const Center(
                      child: Text(
                        'No conversations yet.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey,
                        ),
                      ),
                    );
                  }

                  final filteredConversations = _searchText.isEmpty
                      ? conversations
                      : conversations.where((conv) {
                          final title = conv.title.toLowerCase();
                          final messages = conv.messages
                              .map((msg) => msg.text.toLowerCase())
                              .join(' ');
                          final search = _searchText.toLowerCase();
                          return title.contains(search) ||
                              messages.contains(search);
                        }).toList();

                  if (filteredConversations.isEmpty) {
                    debugPrint('Showing no search results message');
                    return const Center(
                      child: Text(
                        'Oopss! No conversation found.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    key: ValueKey(conversations.length),
                    itemCount: filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      debugPrint(
                          'Conversation ${conversation.id}: title=${conversation.title}, messages=${conversation.messages.length}');
                      return ListTile(
                        leading: _isSelectionMode
                            ? Checkbox(
                                value: _selectedConversationIds
                                    .contains(conversation.id),
                                onChanged: (value) {
                                  _toggleSelection(conversation.id);
                                },
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline,
                                  color: AppColors.primary,
                                ),
                              ),
                        title: Text(
                          conversation.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getConversationPreview(conversation),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(conversation.updatedAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                        onTap: _isSelectionMode
                            ? () => _toggleSelection(conversation.id)
                            : () {
                                chatProvider
                                    .setCurrentConversation(conversation.id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChatPage(),
                                    settings: RouteSettings(arguments: {
                                      'from': 'history',
                                      'sourceTabIndex': widget.sourceTabIndex,
                                    }),
                                  ),
                                );
                              },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final chatProvider = context.read<ChatProvider>();
            await chatProvider.createNewConversation(title: 'New Conversation');
            if (mounted) {
              debugPrint('Navigating to new conversation');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatPage(),
                  settings: RouteSettings(arguments: {
                    'from': 'history',
                    'sourceTabIndex': widget.sourceTabIndex,
                  }),
                ),
              );
            }
          },
          backgroundColor: AppColors.primary,
          child: const Icon(
            Icons.add,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
