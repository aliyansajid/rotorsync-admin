import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_user.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  Set<String> selectedUsers = {}; // Store selected user IDs

  void _toggleSelection(String userId) {
    setState(() {
      final updatedSelection = Set<String>.from(selectedUsers);
      if (updatedSelection.contains(userId)) {
        updatedSelection.remove(userId);
      } else {
        updatedSelection.add(userId);
      }
      selectedUsers = updatedSelection; // Assign updated selection
    });
  }

  Future<void> deleteUsers() async {
    for (var userId in selectedUsers) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    }
    setState(() {
      selectedUsers.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User deleted successfully.")),
    );
  }

  void _editUser(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectedUsers.isNotEmpty
          ? AppBar(
              backgroundColor: const Color(0xFF1D61E7),
              title: Text("${selectedUsers.length} selected",
                  style: const TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    selectedUsers.clear();
                  });
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: deleteUsers,
                ),
              ],
            )
          : AppBar(
              backgroundColor: const Color(0xFF1D61E7),
              title: const Text("Users", style: TextStyle(color: Colors.white)),
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
                height: 1, thickness: 0.5, indent: 75, endIndent: 16),
            itemBuilder: (context, index) {
              final user = users[index];
              final String userId = user.id;
              final String firstName = user['firstName'] ?? '';
              final String lastName = user['lastName'] ?? '';
              final String fullName = "$firstName $lastName".trim();
              final String initials =
                  "${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}"
                      .toUpperCase();

              return StatefulBuilder(
                builder: (context, setStateItem) {
                  final bool isSelected = selectedUsers.contains(userId);

                  return GestureDetector(
                    onLongPress: () => _toggleSelection(userId),
                    onTap: selectedUsers.isNotEmpty
                        ? () => _toggleSelection(userId)
                        : null,
                    child: Container(
                      color: isSelected
                          ? const Color(0xFF1D61E7).withOpacity(0.1)
                          : Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? const Color(0xFF1D61E7)
                              : const Color(0xFF1D61E7),
                          radius: 28,
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : Text(
                                  initials.isNotEmpty ? initials : "?",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                        title: Text(
                          fullName.isNotEmpty ? fullName : "Unnamed User",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          user['email'] ?? "No Email",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.edit, color: Color(0xFF1D61E7)),
                          onPressed: () {
                            _editUser(userId);
                          },
                        ),
                      ),
                    ),
                  );
                },
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
