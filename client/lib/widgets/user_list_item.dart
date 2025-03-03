import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';

class UserListItem extends StatelessWidget {
  final String userId;
  final String fullName;
  final String email;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const UserListItem({
    super.key,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final String initials = _getInitials(fullName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isSelected ? AppColors.accent : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            _buildAvatar(initials),
            const SizedBox(width: 16),
            _buildUserInfo(fullName, email),
            _buildEditButton(),
          ],
        ),
      ),
    );
  }

  String _getInitials(String fullName) {
    final List<String> nameParts = fullName.split(' ');
    if (nameParts.isEmpty) return '';
    if (nameParts.length == 1) return nameParts[0][0].toUpperCase();
    return "${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}"
        .toUpperCase();
  }

  Widget _buildAvatar(String initials) {
    return CircleAvatar(
      backgroundColor: AppColors.primary,
      radius: 28,
      child: isSelected
          ? const Icon(LucideIcons.check, color: AppColors.white)
          : Text(
              initials,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
    );
  }

  Widget _buildUserInfo(String fullName, String email) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return IconButton(
      icon: const Icon(LucideIcons.pencil, color: AppColors.primary),
      onPressed: onEdit,
    );
  }
}
