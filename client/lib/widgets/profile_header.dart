import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ProfileHeader extends StatelessWidget {
  final AsyncSnapshot<Map<String, String>> snapshot;

  const ProfileHeader({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    if (!snapshot.hasData ||
        snapshot.connectionState == ConnectionState.waiting) {
      return _buildSkeleton();
    }

    final data = snapshot.data!;
    final fullName = "${data["firstName"]} ${data["lastName"]}".trim();
    final email = data["email"]!;
    final initials =
        (data["firstName"]!.isNotEmpty && data["lastName"]!.isNotEmpty)
            ? "${data["firstName"]![0]}${data["lastName"]![0]}"
            : "?";

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.white,
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
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
                    fontWeight: FontWeight.bold,
                    color: AppColors.white),
              ),
              Text(
                email,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 28, backgroundColor: AppColors.white),
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
  }

  Widget _buildSkeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
