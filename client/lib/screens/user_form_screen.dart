import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import 'package:rotorsync_admin/widgets/custom_button.dart';
import 'package:rotorsync_admin/widgets/input_field.dart';
import 'package:rotorsync_admin/widgets/label.dart';
import '../controllers/user_form_controller.dart';
import '../utils/validators.dart';

class UserFormScreen extends StatefulWidget {
  final String? userId;
  final Map<String, dynamic>? initialData;

  const UserFormScreen({this.userId, this.initialData, super.key});

  @override
  UserFormScreenState createState() => UserFormScreenState();
}

class UserFormScreenState extends State<UserFormScreen> {
  late UserFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserFormController(
      userId: widget.userId,
      initialData: widget.initialData,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _controller,
      child: Consumer<UserFormController>(
        builder: (context, controller, _) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              appBar: _buildAppBar(),
              backgroundColor: AppColors.white,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFirstNameField(),
                        const SizedBox(height: 16),
                        _buildLastNameField(),
                        const SizedBox(height: 16),
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 16),
                        _buildRoleField(),
                        const SizedBox(height: 32),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      title: Text(
        widget.userId != null ? "Edit User" : "Create User",
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFirstNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "First Name"),
        const SizedBox(height: 8),
        InputField(
          controller: _controller.firstNameController,
          hintText: "John",
          validator: Validators.validateFirstName,
        ),
      ],
    );
  }

  Widget _buildLastNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Last Name"),
        const SizedBox(height: 8),
        InputField(
          controller: _controller.lastNameController,
          hintText: "Doe",
          validator: Validators.validateLastName,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Email"),
        const SizedBox(height: 8),
        InputField(
          controller: _controller.emailController,
          hintText: "john.doe@example.com",
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Password"),
        const SizedBox(height: 8),
        InputField(
          controller: _controller.passwordController,
          hintText: widget.userId == null
              ? "••••••••"
              : "Enter new password (optional)",
          isPassword: true,
          validator: Validators.validatePassword,
        ),
      ],
    );
  }

  Widget _buildRoleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Role"),
        const SizedBox(height: 8),
        InputField(
          hintText: "Select Role",
          items: const ['Admin', 'Pilot', 'Ground Crew'],
          value: _controller.role,
          onChanged: (value) {
            if (value != null) {
              setState(() => _controller.role = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<UserFormController>(
      builder: (context, controller, _) {
        return CustomButton(
          text: widget.userId != null ? "Update" : "Create",
          icon:
              widget.userId != null ? LucideIcons.refreshCcw : LucideIcons.plus,
          isLoading: controller.isLoading,
          onPressed: controller.isLoading
              ? null
              : () => controller.submitForm(context),
        );
      },
    );
  }
}
