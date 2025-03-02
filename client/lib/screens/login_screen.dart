import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/login_controller.dart';
import '../screens/home_screen.dart';
import '../constants/colors.dart';
import '../utils/validators.dart';
import '../widgets/label.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: const Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                _WelcomeMessage(),
                SizedBox(height: 40),
                _LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Welcome message widget
class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          "Welcome Back!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Enter email and password to login",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}

// Login form widget
class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

  final LoginController _loginController = LoginController();

  // Handle login
  Future<void> _login() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _loginController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Clear error messages
  void _clearErrors() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Label(text: "Email"),
          const SizedBox(height: 8),
          InputField(
            controller: _emailController,
            hintText: "john.doe@example.com",
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                _errorMessage ?? Validators.validateEmail(value),
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 16),
          const Label(text: "Password"),
          const SizedBox(height: 8),
          InputField(
            controller: _passwordController,
            hintText: "••••••••",
            focusNode: _passwordFocusNode,
            isPassword: true,
            validator: (value) =>
                _errorMessage ?? Validators.validatePassword(value),
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: "Log In",
            icon: LucideIcons.logIn,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _login,
          ),
        ],
      ),
    );
  }
}
