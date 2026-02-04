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

/// Student screen for searching by batch
class StudentScreen extends StatefulWidget {
  final DataRepository repo;

  const StudentScreen({super.key, required this.repo});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final _searchController = TextEditingController();
  String _selectedDepartment = 'EdTE';
  List _scheduleEntries = [];
  bool _hasSearched = false;
  String? _errorMessage;

  void _searchSchedule() {
    final batchQuery = _searchController.text.trim();
    if (batchQuery.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a batch';
        _hasSearched = false;
      });
      return;
    }

    final day = todayAbbrev();
    
    // Try to find batch
    dynamic batch;
    for (var b in widget.repo.data!.batches) {
      if (b.name.toLowerCase().contains(batchQuery.toLowerCase())) {
        batch = b;
        break;
      }
    }

    if (batch == null) {
      setState(() {
        _errorMessage = 'Batch not found';
        _hasSearched = true;
        _scheduleEntries = [];
      });
      return;
    }

    final entries = widget.repo.batchEntriesForDay(batch.id, day);
    
    setState(() {
      _scheduleEntries = entries;
      _hasSearched = true;
      _errorMessage = entries.isEmpty ? 'No classes today for ${batch.name}' : null;
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
                      color: const Color(0xFF5B7CFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Student',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
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
                      hintText: 'Enter Batch - 60_C',
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
            icon: Icons.school,
            primaryColor: Color(0xFF5B7CFF),
            secondaryColor: Color(0xFF8A5BFF),
            size: 250,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Search for your batch to view your class schedule',
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
