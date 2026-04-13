import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final bool isDanger;
  final VoidCallback? onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.imagePath,
    this.onPressed,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),

        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Row(
          children: [
            // 🔥 ICON CONTAINER
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),

              child: Image.asset(
                imagePath,
                fit: BoxFit.contain, // ✅ VERY IMPORTANT
              ),
            ),

            const SizedBox(width: 20),

            // 🔥 TEXT
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDanger ? AppColors.danger : Colors.black,
                ),
              ),
            ),

            // 🔥 OPTIONAL ARROW (nice UX)
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}