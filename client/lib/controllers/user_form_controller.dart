import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rotorsync_admin/widgets/custom_snackbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserFormController extends ChangeNotifier {
  static const String userCreatedMessage = "User created successfully.";
  static const String userUpdatedMessage = "User updated successfully.";
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String role = 'Admin';
  bool isLoading = false;

  final String? userId;
  final Map<String, dynamic>? initialData;

  UserFormController({this.userId, this.initialData}) {
    if (initialData != null) {
      firstNameController.text = initialData!['firstName'] ?? '';
      lastNameController.text = initialData!['lastName'] ?? '';
      emailController.text = initialData!['email'] ?? '';
      role = initialData!['role'] ?? 'Admin';
    }
  }

  Future<void> submitForm(BuildContext context) async {
    if (isLoading) return;

    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> userData = {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'role': role,
        if (passwordController.text.isNotEmpty)
          'password': passwordController.text.trim(),
      };

      final response = userId == null
          ? await _sendCreateUserRequest(userData)
          : await _sendUpdateUserRequest(userData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          Navigator.pop(context);
          customSnackbar(
            context,
            userId == null ? userCreatedMessage : userUpdatedMessage,
          );
        }
      } else {
        throw Exception(
            'Failed to ${userId == null ? 'create' : 'update'} user');
      }
    } catch (e) {
      if (context.mounted) {
        customSnackbar(
          context,
          "Error: ${e.toString()}",
          isError: true,
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response> _sendCreateUserRequest(
      Map<String, dynamic> userData) async {
    final url = '$backendUrl/api/users/create';
    return await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
  }

  Future<http.Response> _sendUpdateUserRequest(
      Map<String, dynamic> userData) async {
    final url = '$backendUrl/api/users/update/$userId';
    return await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
