import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EditableField extends StatelessWidget {
  final String label;
  final String value;
  final Function() onEditTap;
  final bool isEmail;
  final bool showEditIcon;
  final Widget? suffix;

  const EditableField({
    super.key,
    required this.label,
    required this.value,
    required this.onEditTap,
    this.isEmail = false,
    this.showEditIcon = true,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.grey,
              ),
            ),
            if (isEmail && suffix != null) ...[
              const SizedBox(width: 8),
              suffix!,
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (showEditIcon)
                  InkWell(
                    onTap: onEditTap,
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
