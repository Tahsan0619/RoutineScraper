import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Department dropdown widget
class DepartmentDropdown extends StatelessWidget {
  final String value;
  final Function(String?) onChanged;

  const DepartmentDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF2A2A2A),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
        items: ['EdTE', 'IRE', 'DSE', 'SWE', 'CySE'].map((String dept) {
          return DropdownMenuItem<String>(
            value: dept,
            child: Text(dept),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
