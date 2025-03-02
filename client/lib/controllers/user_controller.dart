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
      int deletedCount = _selectedUsers.length;
      await _userService.deleteUsers(_selectedUsers);

      _selectedUsers.clear();

      if (context.mounted) {
        String message = deletedCount == 1
            ? "User deleted successfully."
            : "$deletedCount users deleted successfully.";
        customSnackbar(context, message);
      }
    } catch (e) {
      if (context.mounted) {
        customSnackbar(context, "Failed to delete user(s): $e", isError: true);
      }
    }
  }
}
