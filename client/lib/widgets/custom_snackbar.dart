import 'package:flutter/material.dart';
import '../constants/colors.dart';

void customSnackbar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: AppColors.white),
      ),
      backgroundColor: isError ? AppColors.red : AppColors.green,
      duration: const Duration(seconds: 3),
    ),
  );
}
