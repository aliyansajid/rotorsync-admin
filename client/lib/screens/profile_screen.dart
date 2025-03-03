import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../controllers/profile_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';
import '../widgets/label.dart';
import '../utils/validators.dart';

class ProfileScreen extends StatelessWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(uid: uid),
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              appBar: _buildAppBar(context),
              backgroundColor: AppColors.white,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              _getInitials(controller.fullNameController.text),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildFullNameField(controller),
                        const SizedBox(height: 16),
                        _buildEmailField(controller),
                        const SizedBox(height: 16),
                        _buildPasswordField(controller),
                        const SizedBox(height: 32),
                        _buildSubmitButton(context, controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return "NA";

    final parts = fullName.trim().split(' ');
    final firstNameInitial = parts[0][0].toUpperCase();
    final lastNameInitial =
        parts.length > 1 ? parts[parts.length - 1][0].toUpperCase() : '';

    return '$firstNameInitial$lastNameInitial';
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      title: const Text(
        "Profile",
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFullNameField(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Full Name"),
        const SizedBox(height: 8),
        Selector<ProfileController, TextEditingController>(
          selector: (_, controller) => controller.fullNameController,
          builder: (context, controller, _) {
            return InputField(
              controller: controller,
              hintText: "John Doe",
              validator: Validators.validateFullName,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmailField(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Email"),
        const SizedBox(height: 8),
        Selector<ProfileController, TextEditingController>(
          selector: (_, controller) => controller.emailController,
          builder: (context, controller, _) {
            return InputField(
              controller: controller,
              hintText: "john.doe@example.com",
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Password"),
        const SizedBox(height: 8),
        Selector<ProfileController, TextEditingController>(
          selector: (_, controller) => controller.passwordController,
          builder: (context, controller, _) {
            return InputField(
              controller: controller,
              hintText: "••••••••",
              isPassword: true,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators.validatePassword(value);
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, ProfileController controller) {
    return Selector<ProfileController, bool>(
      selector: (_, controller) => controller.isLoading,
      builder: (context, isLoading, _) {
        return CustomButton(
          text: "Update",
          icon: LucideIcons.refreshCcw,
          isLoading: isLoading,
          onPressed: isLoading ? null : () => controller.submitForm(context),
        );
      },
    );
  }
}
