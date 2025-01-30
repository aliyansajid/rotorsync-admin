import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateUserScreen extends StatefulWidget {
  final String? userId;
  final Map<String, dynamic>? initialData;

  const CreateUserScreen({this.userId, this.initialData, super.key});

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User saved successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save user: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            style: const TextStyle(fontSize: 17),
          ),
          backgroundColor: const Color(0xFF1D61E7),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                            _buildLabel("First Name"),
                            const SizedBox(height: 8),
                            _buildInputField(
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
                            _buildLabel("Last Name"),
                            const SizedBox(height: 8),
                            _buildInputField(
                              controller: _lastNameController,
                              hintText: "Doe",
                              focusNode: _lastNameFocusNode,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Email"),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _emailController,
                    hintText: "john.doe@gmail.com",
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  if (widget.userId == null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Password"),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _passwordController,
                          hintText: "••••••••",
                          focusNode: _passwordFocusNode,
                          isPassword: true,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  _buildLabel("Role"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _role,
                    items: const [
                      DropdownMenuItem(
                          value: 'Ground Crew', child: Text('Ground Crew')),
                      DropdownMenuItem(value: 'Pilot', child: Text('Pilot')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _role = value);
                    },
                    decoration: _buildInputDecoration(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color(0xFF1D61E7),
                      ),
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.userId != null ? "Update" : "Create",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String labelText) {
    return Text(
      labelText,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6C7278),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required.";
        }
        return null;
      },
      cursorColor: Colors.black,
      decoration: _buildInputDecoration(hintText),
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1A1C1E),
      ),
    );
  }

  InputDecoration _buildInputDecoration([String hintText = ""]) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFEDF1F3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFEDF1F3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF1D61E7),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
    );
  }
}
