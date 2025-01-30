import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rotorsync_admin/screens/login_screen.dart';
import 'package:rotorsync_admin/screens/mqtt_configuration.dart';
import 'package:rotorsync_admin/screens/profile_screen.dart';
import 'package:rotorsync_admin/widgets/settings_option.dart';
import 'package:rotorsync_admin/widgets/custom_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<Map<String, String>> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? "No Email";
    String firstName = "";
    String lastName = "";

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        firstName = userDoc.get("firstName") ?? "";
        lastName = userDoc.get("lastName") ?? "";
      }
    }
    return {"email": email, "firstName": firstName, "lastName": lastName};
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 17),
        ),
        backgroundColor: const Color(0xFF1D61E7),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(snapshot),
                const SizedBox(height: 20),
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
                const SizedBox(height: 8),
                SettingsOption(
                  icon: LucideIcons.user2,
                  title: "Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
                const SizedBox(height: 8),
                SettingsOption(
                  icon: LucideIcons.cloud,
                  title: "MQTT",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MqttScreen()),
                    );
                  },
                ),
                const Spacer(),
                CustomButton(
                  text: "Logout",
                  icon: LucideIcons.logOut,
                  isLoading: false,
                  isDestructive: true,
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(AsyncSnapshot<Map<String, String>> snapshot) {
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
              radius: 30,
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
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                initials.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D61E7),
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
