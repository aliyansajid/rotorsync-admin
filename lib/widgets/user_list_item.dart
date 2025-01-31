import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserListItem extends StatelessWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const UserListItem({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final String fullName = "$firstName $lastName".trim();
    final String initials =
        "${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}"
            .toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isSelected
            ? const Color(0xFF1D61E7).withOpacity(0.1)
            : Colors.transparent,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          leading: CircleAvatar(
            backgroundColor:
                isSelected ? const Color(0xFF1D61E7) : const Color(0xFF1D61E7),
            radius: 28,
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : Text(
                    initials.isNotEmpty ? initials : "?",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
          ),
          title: Text(
            fullName.isNotEmpty ? fullName : "Unnamed User",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(LucideIcons.pencil, color: Color(0xFF1D61E7)),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}
