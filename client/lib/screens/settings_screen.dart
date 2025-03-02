import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../constants/colors.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_option.dart';
import '../widgets/custom_button.dart';
import 'profile_screen.dart';
import 'mqtt_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.read<SettingsController>();
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.white,
      body: _buildBody(context, settingsController),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      title: const Text(
        "Settings",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, SettingsController settingsController) {
    return StreamBuilder<Map<String, String>>(
      stream: settingsController.getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No user data found'));
        }

        final userData = snapshot.data;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(snapshot: snapshot),
              const SizedBox(height: 20),
              _buildSettingsOptions(context, userData),
              const Spacer(),
              _buildLogoutButton(context, settingsController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsOptions(
      BuildContext context, Map<String, String>? userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "General",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary),
        ),
        const SizedBox(height: 8),
        SettingsOption(
          icon: LucideIcons.user2,
          title: "Profile",
          onTap: () {
            if (userData != null && userData["uid"] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(uid: userData["uid"]!),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User ID not found")),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        SettingsOption(
          icon: LucideIcons.cloud,
          title: "MQTT",
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MqttScreen())),
        ),
        const SizedBox(height: 8),
        const SettingsOption(
            icon: LucideIcons.messageCircle, title: "Message Test"),
      ],
    );
  }

  Widget _buildLogoutButton(
      BuildContext context, SettingsController settingsController) {
    return CustomButton(
      text: "Logout",
      icon: LucideIcons.logOut,
      isLoading: false,
      isDestructive: true,
      onPressed: () => settingsController.logout(context),
    );
  }
}
