import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import '../../../../core/constants/app_colors.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;

  const ChatInputField({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _canSend = false;

  // Animation related properties
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateCanSend);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Define animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCanSend);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateCanSend() {
    final canSend = _controller.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() {
        _canSend = canSend;
      });
    }
  }

  void _handleSend() {
    if (_canSend) {
      // Play button press animation
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Send the message
      final message = _controller.text.trim();
      widget.onSendMessage(message);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
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
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.send,
              maxLines: null,
              minLines: 1,
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          // Send button with scale animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: _canSend ? _handleSend : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _canSend ? AppColors.white : Colors.grey.shade300,
                  boxShadow: _canSend
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Image.asset(
                    AssetPath.iconSend,
                    width: 24,
                    height: 24,
                    color: _canSend ? null : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
