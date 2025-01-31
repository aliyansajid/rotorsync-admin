import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_user.dart';
import 'package:rotorsync_admin/widgets/user_list_item.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  UsersScreenState createState() => UsersScreenState();
}

class UsersScreenState extends State<UsersScreen> {
  final Set<String> _selectedUsers = {};

  void _toggleSelection(String userId) {
    setState(() {
      if (_selectedUsers.contains(userId)) {
        _selectedUsers.remove(userId);
      } else {
        _selectedUsers.add(userId);
      }
    });
  }

  Future<void> _deleteUsers() async {
    try {
      for (var userId in _selectedUsers) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();
      }

      if (!mounted) return;
      setState(() {
        _selectedUsers.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User(s) deleted successfully.")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete user(s): $e")),
      );
    }
  }

  void _editUser(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateUserScreen(
              userId: userId,
              initialData: userData,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to edit user: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedUsers.isNotEmpty
          ? AppBar(
              backgroundColor: const Color(0xFF1D61E7),
              title: Text(
                "${_selectedUsers.length} selected",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedUsers.clear();
                  });
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.trash2, color: Colors.white),
                  onPressed: _deleteUsers,
                ),
              ],
            )
          : AppBar(
              backgroundColor: const Color(0xFF1D61E7),
              title: const Text(
                "Users",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          final users = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.only(top: 8.0),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 0.5,
              indent: 75,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final user = users[index];
              final String userId = user.id;
              final String firstName = user['firstName'] ?? '';
              final String lastName = user['lastName'] ?? '';
              final String email = user['email'] ?? 'No Email';

              return UserListItem(
                userId: userId,
                firstName: firstName,
                lastName: lastName,
                email: email,
                isSelected: _selectedUsers.contains(userId),
                onTap: () => _toggleSelection(userId),
                onEdit: () => _editUser(userId),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1D61E7),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateUserScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
