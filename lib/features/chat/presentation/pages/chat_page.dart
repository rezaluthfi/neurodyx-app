import 'package:flutter/material.dart';
import 'package:neurodyx/core/widgets/custom_snack_bar.dart';
import 'package:neurodyx/features/main/presentation/pages/main_navigator.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/assets_path.dart';
import '../../../scan/data/services/tts/tts_engine_manager.dart';
import '../../domain/entities/chat_entity.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/chat_message_widget.dart';
import 'chat_history_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  late final TtsEngineManager _ttsEngineManager;
  bool _isTtsInitialized = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint('ChatPage initState called');
    _ttsEngineManager = TtsEngineManager();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
      _initTts();
    });
  }

  Future<void> _initTts() async {
    try {
      await _ttsEngineManager.initialize(
        onStart: () {
          debugPrint('TTS playback started');
        },
        onComplete: () {
          debugPrint('TTS playback completed');
        },
        onCancel: () {
          debugPrint('TTS playback cancelled');
        },
        onError: (msg) {
          debugPrint('TTS error: $msg');
          CustomSnackBar.show(
            context,
            message: "TTS error: $msg",
            type: SnackBarType.error,
          );
        },
      );
      if (mounted) {
        setState(() {
          _isTtsInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Failed to initialize TTS: $e');
      CustomSnackBar.show(
        context,
        message: "Failed to initialize TTS",
        type: SnackBarType.error,
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _speakText(String text) async {
    if (_isTtsInitialized) {
      try {
        await _ttsEngineManager.speak(text);
      } catch (e) {
        debugPrint('Error speaking text: $e');
        CustomSnackBar.show(
          context,
          message: "Error speaking text",
          type: SnackBarType.error,
        );
      }
    } else {
      debugPrint('TTS engine not initialized yet');
      CustomSnackBar.show(
        context,
        message: "TTS engine not initialized",
        type: SnackBarType.error,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ttsEngineManager.dispose();
    super.dispose();
  }

  // Improved helper method for back navigation with consistent behavior
  void _handleBackNavigation(BuildContext context, dynamic args) {
    debugPrint('ChatPage back navigation triggered with args: $args');

    // Parse navigation source information
    final Map<String, dynamic> routeMap =
        args is Map<String, dynamic> ? args : {};
    final String? fromSource = routeMap['from'] as String?;
    final int sourceTabIndex = routeMap['sourceTabIndex'] ?? 0;

    if (fromSource == 'history') {
      // Coming from ChatHistoryPage, simply pop back to history
      debugPrint('Navigating back to ChatHistoryPage');
      Navigator.pop(context);
    } else {
      // Coming from MainNavigator or other source, return to MainNavigator with original tab
      debugPrint('Navigating back to MainNavigator with tab: $sourceTabIndex');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainNavigator(
            initialIndex: sourceTabIndex,
          ),
        ),
        (route) => false, // Clear all routes from stack
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get arguments from the route
    final args = ModalRoute.of(context)?.settings.arguments;
    debugPrint('ChatPage build with args: $args');

    return PopScope(
      canPop: false, // Handle back behavior manually
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Use the helper method for consistent back navigation
        _handleBackNavigation(context, args);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(
            'Neurodyx Assistant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            // Using same helper method for appbar back button
            onPressed: () => _handleBackNavigation(context, args),
            tooltip: 'Back',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                final Map<String, dynamic> routeMap =
                    args is Map<String, dynamic> ? args : {};
                final int sourceTabIndex = routeMap['sourceTabIndex'] ?? 0;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatHistoryPage(
                      sourceTabIndex: sourceTabIndex,
                    ),
                  ),
                );
              },
              tooltip: 'Chat History',
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      'About This Chatbot',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      'This chatbot is designed to support individuals with dyslexia. You can ask questions about dyslexia, share your experiences, or get tips on coping strategies. The chatbot uses Gemini AI to provide helpful and empathetic responses.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'About Chatbot',
            ),
          ],
        ),
        body: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            final currentConversation = chatProvider.currentConversation;

            if (currentConversation == null && !_hasNavigated) {
              debugPrint('No current conversation, showing error message');
              _hasNavigated = true;

              return const Center(
                child: Text(
                  'No conversation selected...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey,
                  ),
                ),
              );
            }

            if (currentConversation != null &&
                currentConversation.messages.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }

            return Column(
              children: [
                Expanded(
                  child: currentConversation == null ||
                          currentConversation.messages.isEmpty
                      ? _buildWelcomeMessage()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: currentConversation.messages.length,
                          itemBuilder: (context, index) {
                            final message = currentConversation.messages[index];
                            return ChatMessageWidget(
                              message: message,
                              onTapToSpeak:
                                  message.role == MessageRole.assistant
                                      ? () => _speakText(message.text)
                                      : null,
                            );
                          },
                        ),
                ),
                _buildInputWithPoweredBy(chatProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputWithPoweredBy(ChatProvider chatProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8.0 : 0,
                top: 8.0,
              ),
              child: ChatInputField(
                onSendMessage: chatProvider.sendMessage,
                isLoading: chatProvider.isLoading,
              ),
            ),
            if (MediaQuery.of(context).viewInsets.bottom == 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Text(
                        'Powered by ',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: SizedBox(
                        height: 24,
                        child: Image.asset(
                          AssetPath.logoGemini,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              HeroMode(
                enabled: false,
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 72,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Dyslexia Support Chat',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ask me anything about dyslexia, share your experiences, or get support for your challenges.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'Tap the button below to start a conversation',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              HeroMode(
                enabled: false,
                child: Icon(
                  Icons.arrow_downward,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
