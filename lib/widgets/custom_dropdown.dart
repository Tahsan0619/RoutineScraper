import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom dropdown widget
class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final Function(T?) onChanged;

  const CustomDropdown({
    super.key,
    this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Text(
          hint,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF2A2A2A),
        style: GoogleFonts.poppins(color: Colors.white),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
