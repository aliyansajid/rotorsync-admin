import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rotorsync_admin/screens/login_screen.dart';
import 'package:rotorsync_admin/screens/mqtt_configuration.dart';
import 'package:rotorsync_admin/screens/profile_screen.dart';
import 'package:rotorsync_admin/widgets/profile_header.dart';
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

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF1D61E7),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, String>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(snapshot: snapshot),
                const SizedBox(height: 20),
                const Text(
                  "General",
                  style: TextStyle(
                    fontSize: 15,
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
}
