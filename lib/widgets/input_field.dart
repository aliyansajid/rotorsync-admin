import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    _isPasswordVisible = widget.isPassword ? false : true;
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
      cursorColor: Colors.black,
      enabled: widget.enabled,
      decoration: _buildInputDecoration(
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                  color: const Color(0xFFACB5BB),
                  size: 20,
                ),
                onPressed: widget.enabled
                    ? () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      }
                    : null,
              )
            : null,
      ),
      style: _buildTextStyle(),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: widget.value,
      items: widget.items!
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: widget.enabled ? widget.onChanged : null,
      decoration: _buildInputDecoration(),
      style: _buildTextStyle(),
    );
  }

  InputDecoration _buildInputDecoration({Widget? suffixIcon}) {
    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: const TextStyle(color: Color(0xFFACB5BB), fontSize: 14),
      filled: true,
      fillColor: widget.enabled ? Colors.white : const Color(0xFFEDF1F3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1D61E7), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }

  TextStyle _buildTextStyle() {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: widget.enabled ? const Color(0xFF1A1C1E) : const Color(0xFFACB5BB),
    );
  }
}
