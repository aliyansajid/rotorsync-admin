import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rotorsync_admin/widgets/custom_snackbar.dart';
import '../services/user_service.dart';

class UsersController {
  final Set<String> _selectedUsers = {};
  final UserService _userService = UserService();
  final Stream<QuerySnapshot<Map<String, dynamic>>> usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  Set<String> get selectedUsers => _selectedUsers;

  void toggleSelection(String userId) {
    _selectedUsers.contains(userId)
        ? _selectedUsers.remove(userId)
        : _selectedUsers.add(userId);
  }

  Future<void> deleteUsers(BuildContext context) async {
    if (!context.mounted) return;

    try {
      final response = await _userService.deleteUsers(_selectedUsers);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final message =
            responseBody['message'] ?? 'Users deleted successfully.';

        _selectedUsers.clear();

        if (context.mounted) {
          customSnackbar(context, message);
        }
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['error'] ?? 'Failed to delete users.';
        throw errorMessage;
      }
    } catch (e) {
      if (context.mounted) {
        customSnackbar(context, "Error: $e", isError: true);
      }
    }
  }
}
