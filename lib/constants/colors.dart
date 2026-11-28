import 'package:flutter/material.dart';

class AppColors {
  // Existing colors (used by the patient side) — unchanged
  static const Color primary = Color(0xFF8FAEC9);
  static const Color background = Color(0xFFF2F2F2);
  static const Color textPrimary = Colors.black;
  static const Color danger = Colors.red;

  // Caregiver redesign palette (same blue family + light green)
  static const Color blue = Color(0xFF8FAAC3); // main card blue
  static const Color deepBlue = Color(0xFF4E6A87); // headers, buttons
  static const Color lightBlue = Color(0xFFDCE5EF); // icon badges, chips
  static const Color softBlue = Color(0xFFEEF2F7);
  static const Color grey = Color(0xFFEEEEEE); // page background

  static const Color green = Color(0xFF2E7D32); // done / call
  static const Color greenText = Color(0xFF1E6B23);
  static const Color lightGreen = Color(0xFFDFF2E1); // task cards
  static const Color midGreen = Color(0xFFBFE3C3); // task icon badges
  static const Color progressGreen = Color(0xFFA5D6A7); // progress bars

  static const Color ink = Color(0xFF1C2A3A); // main text
  static const Color muted = Color(0xFF55667A); // secondary text
}
