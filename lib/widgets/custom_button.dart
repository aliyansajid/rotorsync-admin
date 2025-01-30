import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool isDestructive;

  const CustomButton({
    super.key,
    required this.text,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Stack(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: isLoading
                  ? const Color(0xFFEDF1F3)
                  : isDestructive
                      ? Colors.red
                      : const Color(0xFF1D61E7),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: isLoading
                ? null
                : () {
                    onPressed?.call();
                  },
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
