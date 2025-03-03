import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rotorsync_admin/widgets/custom_snackbar.dart';
import '../services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  final String uid;
  final ProfileService _profileService = ProfileService();

  ProfileController({required this.uid}) {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    isLoading = true;
    notifyListeners();

    try {
      final userData = await _profileService.fetchUserData(uid);
      fullNameController.text = userData['fullName'] ?? '';
      emailController.text = userData['email'] ?? '';
    } catch (e) {
      throw Exception("Error fetching user data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitForm(BuildContext context) async {
    if (isLoading || !formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> userData = {
        'fullName': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        if (passwordController.text.isNotEmpty)
          'password': passwordController.text.trim(),
      };

      final response = await _profileService.updateUser(uid, userData);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          customSnackbar(
            context,
            responseBody['message'] ?? 'Profile updated successfully.',
          );
        }
      } else {
        final errorMessage = responseBody['error'] ?? 'Unknown error occurred.';
        throw errorMessage;
      }
    } catch (e) {
      if (context.mounted) {
        customSnackbar(
          context,
          "Error: $e",
          isError: true,
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
