import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const SettingsOption({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1D61E7).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF1D61E7)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1C1E),
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          size: 20,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
