import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rotorsync_admin/utils/validators.dart';
import '../constants/colors.dart';
import '../controllers/profile_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';
import '../widgets/label.dart';

class ProfileScreen extends StatefulWidget {
  final String uid; // Add uid as a parameter
  const ProfileScreen({super.key, required this.uid});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final ProfileController _profileController;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController(uid: widget.uid);
    _fetchUserData();
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await _profileController.fetchUserData();
      if (mounted) {
        setState(() {
          emailController.text = userData["email"] ?? "";
          firstNameController.text = userData["firstName"] ?? "";
          lastNameController.text = userData["lastName"] ?? "";
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching user data: $e")),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _profileController.updateProfile(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        password: passwordController.text,
        context: context,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
        backgroundColor: AppColors.white,
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              (firstNameController.text.isNotEmpty ||
                                      lastNameController.text.isNotEmpty)
                                  ? "${firstNameController.text.isNotEmpty ? firstNameController.text[0].toUpperCase() : ''}${lastNameController.text.isNotEmpty ? lastNameController.text[0].toUpperCase() : ''}"
                                  : "NA",
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Label(text: "First Name"),
                        const SizedBox(height: 8),
                        InputField(
                            controller: firstNameController, hintText: "John"),
                        const SizedBox(height: 16),
                        const Label(text: "Last Name"),
                        const SizedBox(height: 8),
                        InputField(
                            controller: lastNameController, hintText: "Doe"),
                        const SizedBox(height: 16),
                        const Label(text: "Email"),
                        const SizedBox(height: 8),
                        InputField(
                          controller: emailController,
                          hintText: "john.doe@example.com",
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        const Label(text: "Password"),
                        const SizedBox(height: 8),
                        InputField(
                          controller: passwordController,
                          hintText: "••••••••",
                          isPassword: true,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: "Update",
                          icon: LucideIcons.refreshCcw,
                          isLoading: _isUpdating,
                          onPressed: _isUpdating ? null : _updateProfile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
