import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_repository.dart';
import '../models/teacher.dart';

/// Screen to manage all teachers
class ManageTeachersScreen extends StatefulWidget {
  final DataRepository repo;

  const ManageTeachersScreen({
    super.key,
    required this.repo,
  });

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  late List<Teacher> teachers;
  late List<Teacher> filteredTeachers;
  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    teachers = widget.repo.data?.teachers ?? [];
    filteredTeachers = teachers;
    searchCtrl.addListener(_filterTeachers);
  }

  void _filterTeachers() {
    final query = searchCtrl.text.toLowerCase();
    setState(() {
      filteredTeachers = teachers
          .where((t) =>
              t.name.toLowerCase().contains(query) ||
              t.initial.toLowerCase().contains(query) ||
              t.email.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Manage Teachers',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search teachers...',
                hintStyle: const TextStyle(color: Color(0xFF808080)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF5B7CFF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF5B7CFF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF404040)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF5B7CFF)),
                ),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
              ),
            ),
          ),
          Expanded(
            child: filteredTeachers.isEmpty
                ? Center(
                    child: Text(
                      'No teachers found',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTeachers.length,
                    itemBuilder: (context, index) {
                      final teacher = filteredTeachers[index];
                      return _buildTeacherCard(teacher);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(Teacher teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5B7CFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B7CFF), Color(0xFF8A5BFF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    teacher.initial,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      teacher.designation,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Color(0xFFB0B0B0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[800]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(Icons.email, teacher.email),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoRow(Icons.phone, teacher.phone),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.business, teacher.homeDepartment),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF5B7CFF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Color(0xFFB0B0B0),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
