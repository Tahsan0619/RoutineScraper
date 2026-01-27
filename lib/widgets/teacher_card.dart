import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/teacher.dart';

/// Teacher information card
class TeacherCard extends StatelessWidget {
  final Teacher teacher;

  const TeacherCard({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          runSpacing: 6,
          spacing: 24,
          children: [
            _InfoTile(label: 'Name', value: teacher.name),
            _InfoTile(label: 'Initial', value: teacher.initial),
            _InfoTile(label: 'Designation', value: teacher.designation),
            _InfoTile(label: 'Department', value: teacher.homeDepartment),
            _InfoTile(label: 'Phone', value: teacher.phone),
            _InfoTile(label: 'Email', value: teacher.email),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }
}
