import 'package:flutter/material.dart';

class VerifiedStatusBadge extends StatelessWidget {
  final bool isVerified;
  final Function() onSendVerification;
  final bool isCompact;

  const VerifiedStatusBadge({
    super.key,
    required this.isVerified,
    required this.onSendVerification,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    // Compact badge design - can be placed next to Email field
    if (isCompact) {
      return InkWell(
        onTap: isVerified ? null : onSendVerification,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isVerified
                ? Colors.green.withOpacity(0.1)
                : Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isVerified ? Colors.green.shade300 : Colors.amber.shade300,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVerified ? Icons.check_circle : Icons.info_outline,
                color: isVerified ? Colors.green : Colors.amber.shade700,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                isVerified ? 'Verified' : 'Not Verified',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isVerified ? Colors.green : Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Alternative tooltip-style design
    return Tooltip(
      message:
          isVerified ? 'Email is verified' : 'Click to send verification email',
      child: InkWell(
        onTap: isVerified ? null : onSendVerification,
        child: Icon(
          isVerified ? Icons.verified : Icons.error_outline,
          color: isVerified ? Colors.green : Colors.amber.shade700,
          size: 18,
        ),
      ),
    );
  }
}
