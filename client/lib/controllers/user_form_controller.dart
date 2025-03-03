import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rotorsync_admin/widgets/custom_snackbar.dart';
import 'package:rotorsync_admin/services/user_service.dart';

class UserFormController extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String role = 'Admin';
  bool isLoading = false;

  final String? userId;
  final Map<String, dynamic>? initialData;

  UserFormController({this.userId, this.initialData}) {
    if (initialData != null) {
      fullNameController.text = initialData!['fullName'] ?? '';
      emailController.text = initialData!['email'] ?? '';
      role = initialData!['role'] ?? 'Admin';
    }
  }

  void updateRole(String newRole) {
    role = newRole;
    notifyListeners();
  }

  Future<void> submitForm(BuildContext context) async {
    if (isLoading || !formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> userData = {
        'fullName': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'role': role,
      };

      if (userId == null || passwordController.text.isNotEmpty) {
        userData['password'] = passwordController.text.trim();
      }

      final response = userId == null
          ? await UserService().createUser(userData)
          : await UserService().updateUser(userId!, userData);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          Navigator.pop(context);
          customSnackbar(
            context,
            responseBody['message'] ?? 'Operation completed successfully.',
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
