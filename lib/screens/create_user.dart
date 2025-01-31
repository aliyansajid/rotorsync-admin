import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rotorsync_admin/widgets/custom_button.dart';
import 'package:rotorsync_admin/widgets/input_field.dart';
import 'package:rotorsync_admin/widgets/label.dart';

class CreateUserScreen extends StatefulWidget {
  final String? userId;
  final Map<String, dynamic>? initialData;

  const CreateUserScreen({this.userId, this.initialData, super.key});

  @override
  CreateUserScreenState createState() => CreateUserScreenState();
}

class CreateUserScreenState extends State<CreateUserScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  String _role = 'Ground Crew';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _firstNameController.text = data['firstName'] ?? '';
      _lastNameController.text = data['lastName'] ?? '';
      _emailController.text = data['email'] ?? '';
      _role = data['role'] ?? 'Ground Crew';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final userData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'role': _role,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update(userData);
      } else {
        await FirebaseFirestore.instance.collection('users').add(userData);
      }

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User saved successfully.")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save user: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.userId != null ? "Edit User" : "Create User",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF1D61E7),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Label(text: "First Name"),
                            const SizedBox(height: 8),
                            InputField(
                              controller: _firstNameController,
                              hintText: "John",
                              focusNode: _firstNameFocusNode,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Label(text: "Last Name"),
                            const SizedBox(height: 8),
                            InputField(
                              controller: _lastNameController,
                              hintText: "John",
                              focusNode: _lastNameFocusNode,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Label(text: "Email"),
                  const SizedBox(height: 8),
                  InputField(
                    controller: _emailController,
                    hintText: "john.doe@example.com",
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  if (widget.userId == null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Label(text: "Password"),
                        const SizedBox(height: 8),
                        InputField(
                          controller: _passwordController,
                          hintText: "••••••••",
                          focusNode: _passwordFocusNode,
                          isPassword: true,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  const Label(text: "Role"),
                  const SizedBox(height: 8),
                  InputField(
                    hintText: "Select Role",
                    items: const ['Ground Crew', 'Pilot'],
                    value: _role,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _role = value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: widget.userId != null ? "Update" : "Create",
                    icon: widget.userId != null
                        ? LucideIcons.refreshCcw
                        : LucideIcons.plus,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _submitForm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
