import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfilePicture extends StatelessWidget {
  final String? profilePictureUrl;
  final String? username;

  const ProfilePicture({super.key, this.profilePictureUrl, this.username});

  @override
  Widget build(BuildContext context) {
    final initial = profilePictureUrl?.startsWith('initial:') == true
        ? profilePictureUrl!.substring(8)
        : (username?.isNotEmpty == true ? username![0].toUpperCase() : '?');

    return Stack(
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: AppColors.primary,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 36,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
