import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rotorsync_admin/widgets/custom_snackbar.dart';

class ProfileController extends ChangeNotifier {
  static const String profileUpdatedMessage = "Profile updated successfully.";
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  final String uid;

  ProfileController({required this.uid});

  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/users/$uid'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch user data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching user data: $e");
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? password,
    required BuildContext context,
  }) async {
    try {
      final Map<String, dynamic> userData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
      };

      final response = await http.put(
        Uri.parse('$backendUrl/api/users/update/$uid'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          customSnackbar(context, profileUpdatedMessage);
        }
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      if (context.mounted) {
        customSnackbar(
          context,
          "Error: ${e.toString()}",
          isError: true,
        );
      }
    }
  }
}
