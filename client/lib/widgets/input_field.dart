import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';

class InputField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;
  final bool enabled;
  final List<String>? items;
  final String? value;

  final void Function(String?)? onChanged;

  const InputField({
    super.key,
    this.controller,
    required this.hintText,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.validator,
    this.enabled = true,
    this.items,
    this.value,
    this.onChanged,
  });

  @override
  InputFieldState createState() => InputFieldState();
}

class InputFieldState extends State<InputField> {
  late bool _isPasswordVisible;

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = !widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return widget.items == null ? _buildTextInput() : _buildDropdown();
  }

  Widget _buildTextInput() {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.isPassword && !_isPasswordVisible,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      enabled: widget.enabled,
      decoration: _buildInputDecoration(
        suffixIcon: widget.isPassword ? _buildPasswordVisibilityToggle() : null,
      ),
      style: _buildTextStyle(),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: widget.value,
      items: widget.items
          ?.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: widget.enabled ? widget.onChanged : null,
      decoration: _buildInputDecoration(),
      style: _buildTextStyle(),
    );
  }

  Widget _buildPasswordVisibilityToggle() {
    return IconButton(
      icon: Icon(
        _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
        color: AppColors.coolGrey,
        size: 20,
      ),
      onPressed: widget.enabled
          ? () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            }
          : null,
    );
  }

  InputDecoration _buildInputDecoration({Widget? suffixIcon}) {
    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: const TextStyle(color: AppColors.coolGrey, fontSize: 14),
      filled: true,
      fillColor: widget.enabled ? AppColors.white : AppColors.offWhite,
      border: _buildBorder(AppColors.offWhite),
      enabledBorder: _buildBorder(AppColors.offWhite),
      disabledBorder: _buildBorder(AppColors.offWhite),
      focusedBorder: _buildBorder(AppColors.primary, width: 2),
      errorStyle: const TextStyle(
        color: AppColors.red,
        fontWeight: FontWeight.w500,
      ),
      errorBorder: _buildBorder(AppColors.red),
      focusedErrorBorder: _buildBorder(AppColors.red, width: 2),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      suffixIcon: suffixIcon,
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  TextStyle _buildTextStyle() {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: widget.enabled ? AppColors.black : AppColors.coolGrey,
    );
  }
}
