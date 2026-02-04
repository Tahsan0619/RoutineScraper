import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/data_repository.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/department_dropdown.dart';
import '../widgets/online_badge.dart';
import '../widgets/schedule_card.dart';
import '../widgets/animated_illustration.dart';
import '../utils/date_utils.dart';

/// Teacher screen for searching by teacher initial
class TeacherScreen extends StatefulWidget {
  final DataRepository repo;

  const TeacherScreen({super.key, required this.repo});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  final _searchController = TextEditingController();
  String _selectedDepartment = 'EdTE';
  List _scheduleEntries = [];
  bool _hasSearched = false;
  String? _errorMessage;
  String? _teacherName;
  dynamic _teacher;

  void _searchSchedule() {
    final initial = _searchController.text.trim().toUpperCase();
    if (initial.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter teacher initial';
        _hasSearched = false;
      });
      return;
    }

    final day = todayAbbrev();
    
    // Try to find teacher
    dynamic teacher;
    for (var t in widget.repo.data!.teachers) {
      if (t.initial.toUpperCase() == initial) {
        teacher = t;
        break;
      }
    }

    if (teacher == null) {
      setState(() {
        _errorMessage = 'Teacher not found';
        _hasSearched = true;
        _scheduleEntries = [];
        _teacherName = null;
        _teacher = null;
      });
      return;
    }

    final entries = widget.repo.teacherEntriesForDay(teacher.id, day);
    
    setState(() {
      _scheduleEntries = entries;
      _hasSearched = true;
      _teacherName = teacher.name;
      _teacher = teacher;
      _errorMessage = entries.isEmpty ? 'No classes today for ${teacher.name}' : null;
    });
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await context.read<SupabaseService>().logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A5BFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Teacher',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const OnlineBadge(),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => _showSettingsMenu(context),
                  ),
                ],
              ),
            ),
            
            // Search Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomSearchBar(
                      controller: _searchController,
                      hintText: 'Enter Teacher Initial - NRC',
                      onSubmitted: (_) => _searchSchedule(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DepartmentDropdown(
                    value: _selectedDepartment,
                    onChanged: (value) => setState(() => _selectedDepartment = value!),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Teacher Profile Card
            if (_teacherName != null && _teacher != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture
                      if (_teacher!.profilePic != null && _teacher!.profilePic!.isNotEmpty)
                        ClipOval(
                          child: Image.network(
                            _teacher!.profilePic!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person, size: 60, color: Colors.grey),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 60, color: Colors.grey),
                        ),
                      const SizedBox(height: 16),
                      // Teacher Name
                      Text(
                        _teacherName!,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Teacher Designation
                      if (_teacher!.designation.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _teacher!.designation,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF444444), thickness: 1),
                      const SizedBox(height: 12),
                      // Teacher Details
                      Column(
                        children: [
                          // Phone
                          if (_teacher!.phone.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone, size: 18, color: Color(0xFF5B7CFF)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _teacher!.phone,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Email
                          if (_teacher!.email.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.email, size: 18, color: Color(0xFF5B7CFF)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _teacher!.email,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[300],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Department
                          if (_teacher!.homeDepartment.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.domain, size: 18, color: Color(0xFF5B7CFF)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _teacher!.homeDepartment,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: _hasSearched
                  ? _scheduleEntries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy, size: 80, color: Colors.grey[700]),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage ?? 'No schedule found',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _scheduleEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _scheduleEntries[index];
                            return ScheduleCard(entry: entry, repo: widget.repo);
                          },
                        )
                  : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AnimatedIllustration(
            icon: Icons.person,
            primaryColor: Color(0xFF8A5BFF),
            secondaryColor: Color(0xFFFF6B9D),
            size: 250,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              "Search for a teacher's initial to view their schedule",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
