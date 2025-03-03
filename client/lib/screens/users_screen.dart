import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../widgets/user_list_item.dart';
import '../controllers/user_controller.dart';
import 'user_form_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  UsersScreenState createState() => UsersScreenState();
}

class UsersScreenState extends State<UsersScreen> {
  final UsersController _controller = UsersController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.white,
      body: _buildUserList(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return _controller.selectedUsers.isNotEmpty
        ? AppBar(
            backgroundColor: AppColors.primary,
            title: Text(
              "${_controller.selectedUsers.length} selected",
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AppColors.white),
              onPressed: () {
                setState(() => _controller.selectedUsers.clear());
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.trash2,
                    color: AppColors.white, size: 20),
                onPressed: () async {
                  await _controller.deleteUsers(context);
                  setState(() {});
                },
              ),
            ],
          )
        : AppBar(
            backgroundColor: AppColors.primary,
            title: const Text(
              "Users",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _controller.usersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading users: ${snapshot.error}",
              style: const TextStyle(color: AppColors.text),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No users found.",
              style: TextStyle(color: AppColors.text),
            ),
          );
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final fullName = user['fullName'] ?? 'John Doe';
            final email = user['email'] ?? 'No Email';

            return Column(
              children: [
                UserListItem(
                  userId: user.id,
                  fullName: fullName,
                  email: email,
                  isSelected: _controller.selectedUsers.contains(user.id),
                  onTap: () =>
                      setState(() => _controller.toggleSelection(user.id)),
                  onEdit: () => _navigateToUserForm(context, user),
                ),
                if (index < users.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(
                      thickness: 1,
                      height: 1,
                      color: AppColors.offWhite,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToUserForm(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(
          userId: user.id,
          initialData: {
            'fullName': user['fullName'] ?? 'John Doe',
            'email': user['email'] ?? 'No Email',
            'role': user['role'] ?? 'Admin',
          },
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserFormScreen(),
          ),
        );
      },
      child: const Icon(LucideIcons.plus, color: AppColors.white),
    );
  }
}
