import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rotorsync_admin/widgets/label.dart';
import 'package:rotorsync_admin/widgets/input_field.dart';
import 'package:rotorsync_admin/widgets/custom_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            firstNameController.text = userDoc['firstName'] ?? "";
            lastNameController.text = userDoc['lastName'] ?? "";
            emailController.text = userDoc['email'] ?? user?.email ?? "";
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        log("Error fetching user data: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateProfile() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'email': emailController.text,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      }
    } catch (e) {
      log("Error updating profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile!')),
        );
      }
    }

    setState(() {
      _isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile",
            style: TextStyle(fontSize: 17),
          ),
          backgroundColor: const Color(0xFF1D61E7),
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF1D61E7),
                    child: Text(
                      "${firstNameController.text.isNotEmpty ? firstNameController.text[0].toUpperCase() : ''}${lastNameController.text.isNotEmpty ? lastNameController.text[0].toUpperCase() : ''}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Label(text: "First Name"),
                const SizedBox(height: 8),
                InputField(controller: firstNameController, hintText: "John"),
                const SizedBox(height: 16),
                const Label(text: "Last Name"),
                const SizedBox(height: 8),
                InputField(controller: lastNameController, hintText: "Doe"),
                const SizedBox(height: 16),
                const Label(text: "Email"),
                const SizedBox(height: 8),
                InputField(
                    controller: emailController,
                    hintText: "john.doe@example.com"),
                const SizedBox(height: 16),
                const Label(text: "Password"),
                const SizedBox(height: 8),
                InputField(
                    controller: passwordController,
                    hintText: "••••••••",
                    isPassword: true),
                const SizedBox(height: 20),
                CustomButton(
                  text: "Update",
                  icon: LucideIcons.refreshCcw,
                  isLoading: _isUpdating,
                  onPressed: _isUpdating ? null : updateProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
