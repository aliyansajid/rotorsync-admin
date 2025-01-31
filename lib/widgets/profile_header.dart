import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final AsyncSnapshot<Map<String, String>> snapshot;

  const ProfileHeader({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    if (!snapshot.hasData) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1D61E7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonBox(width: 120, height: 18),
                const SizedBox(height: 4),
                _buildSkeletonBox(width: 180, height: 14),
              ],
            ),
          ],
        ),
      );
    } else {
      String fullName =
          "${snapshot.data!["firstName"]} ${snapshot.data!["lastName"]}".trim();
      String email = snapshot.data!["email"]!;
      String initials = (snapshot.data!["firstName"]!.isNotEmpty &&
              snapshot.data!["lastName"]!.isNotEmpty)
          ? "${snapshot.data!["firstName"]![0]}${snapshot.data!["lastName"]![0]}"
          : "?";

      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1D61E7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Text(
                initials.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF1D61E7),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSkeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
