import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:rotorsync_admin/controllers/settings_controller.dart';
import '../constants/colors.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_option.dart';
import '../widgets/custom_button.dart';

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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(snapshot: snapshot),
              const SizedBox(height: 20),
              _buildSettingsOptions(),
              const Spacer(),
              _buildLogoutButton(context, settingsController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsOptions() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "General",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary),
        ),
        SizedBox(height: 8),
        SettingsOption(icon: LucideIcons.user2, title: "Profile"),
        SizedBox(height: 8),
        SettingsOption(icon: LucideIcons.cloud, title: "MQTT"),
        SizedBox(height: 8),
        SettingsOption(icon: LucideIcons.messageCircle, title: "Message Test"),
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
