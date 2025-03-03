import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rotorsync_admin/widgets/custom_snackbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/validators.dart';

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

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? passwordError;

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

    firstNameController.addListener(() => validateFirstName());
    lastNameController.addListener(() => validateLastName());
    emailController.addListener(() => validateEmail());
    passwordController.addListener(() => validatePassword());
  }

  void validateFirstName() {
    firstNameError = Validators.validateFirstName(firstNameController.text);
    notifyListeners();
  }

  void validateLastName() {
    lastNameError = Validators.validateLastName(lastNameController.text);
    notifyListeners();
  }

  void validateEmail() {
    emailError = Validators.validateEmail(emailController.text);
    notifyListeners();
  }

  void validatePassword() {
    passwordError = Validators.validatePassword(passwordController.text);
    notifyListeners();
  }

  Future<void> submitForm(BuildContext context) async {
    if (isLoading) return;

    validateFirstName();
    validateLastName();
    validateEmail();
    validatePassword();

    if (firstNameError != null ||
        lastNameError != null ||
        emailError != null ||
        (userId == null && passwordError != null)) {
      return;
    }

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

      if (userId == null) {
        await _createUserInFirebase(userData);
      } else {
        await _sendUpdateUserRequest(userData);
      }

      if (context.mounted) {
        Navigator.pop(context);
        customSnackbar(
            context, userId == null ? userCreatedMessage : userUpdatedMessage);
      }
    } catch (e) {
      if (context.mounted) {
        customSnackbar(context, "Error: ${e.toString()}", isError: true);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createUserInFirebase(Map<String, dynamic> userData) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userData['email'],
        password: userData['password'],
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'firstName': userData['firstName'],
        'lastName': userData['lastName'],
        'email': userData['email'],
        'role': userData['role'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Firebase user creation failed: $e");
    }
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
