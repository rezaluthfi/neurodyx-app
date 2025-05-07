import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/chat_entity.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;
  final Function()? onTapToSpeak;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onTapToSpeak,
  });

  @override
  _ChatMessageWidgetState createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _dotAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller to repeat every 1.5s (500ms per dot state)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Animate between 0, 1, 2 to control number of dots (..., .., .)
    _dotAnimation = IntTween(begin: 0, end: 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.greenMint : AppColors.indigo200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            widget.message.isLoading
                ? AnimatedBuilder(
                    animation: _dotAnimation,
                    builder: (context, _) {
                      final dots = '.' * (3 - _dotAnimation.value);
                      return Text(
                        'Typing$dots',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    },
                  )
                : Text(
                    widget.message.text,
                    style: TextStyle(
                      color: isUser ? AppColors.textPrimary : AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
            if (!isUser && !widget.message.isLoading) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: widget.onTapToSpeak,
                child: const Icon(
                  Icons.volume_up,
                  size: 18,
                  color: AppColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
