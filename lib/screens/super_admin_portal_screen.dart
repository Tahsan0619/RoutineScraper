import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/data_repository.dart';
import '../services/supabase_service.dart';
import '../models/admin.dart';
import '../widgets/online_badge.dart';
import 'add_edit_schedule_screen.dart';
import 'manage_teachers_screen.dart';
import 'manage_batches_screen.dart';
import 'manage_rooms_screen.dart';

/// Super admin portal for complete schedule management with dark theme
class SuperAdminPortalScreen extends StatefulWidget {
  final DataRepository repo;
  final Admin admin;

  const SuperAdminPortalScreen({
    super.key,
    required this.repo,
    required this.admin,
  });

  @override
  State<SuperAdminPortalScreen> createState() => _SuperAdminPortalScreenState();
}

class _SuperAdminPortalScreenState extends State<SuperAdminPortalScreen> {
  int _selectedIndex = 0;

  void _logout() async {
    await context.read<SupabaseService>().logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B7CFF), Color(0xFF8A5BFF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Super Admin',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.admin.username,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const OnlineBadge(),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _logout,
                  ),
                ],
              ),
            ),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Overview', 0, Icons.dashboard),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTabButton('Schedule', 1, Icons.calendar_today),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTabButton('Analytics', 2, Icons.analytics),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildOverviewTab(),
                  _buildScheduleTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showDaySelector(),
              backgroundColor: const Color(0xFF5B7CFF),
              icon: const Icon(Icons.add),
              label: Text('Add Class', style: GoogleFonts.poppins()),
            )
          : null,
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5B7CFF)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[400],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final totalClasses = widget.repo.getAllTimetableEntries().length;
    final totalTeachers = widget.repo.data!.teachers.length;
    final totalBatches = widget.repo.data!.batches.length;
    final totalRooms = widget.repo.data!.rooms.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Classes',
                  totalClasses.toString(),
                  Icons.class_,
                  const Color(0xFF5B7CFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Teachers',
                  totalTeachers.toString(),
                  Icons.person,
                  const Color(0xFF8A5BFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Batches',
                  totalBatches.toString(),
                  Icons.group,
                  const Color(0xFFFF6B9D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Rooms',
                  totalRooms.toString(),
                  Icons.door_front_door,
                  const Color(0xFFFFB74D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          _buildActionCard(
            'Manage Teachers',
            'View and edit teacher information',
            Icons.people,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ManageTeachersScreen(repo: widget.repo),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            'Manage Batches',
            'View and edit batch details',
            Icons.school,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ManageBatchesScreen(repo: widget.repo),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            'Manage Rooms',
            'View and edit room assignments',
            Icons.meeting_room,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ManageRoomsScreen(repo: widget.repo),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            'Bulk Operations',
            'Import/Export schedules and manage data',
            Icons.sync,
            () => _showBulkOperations(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    final allEntries = widget.repo.getAllTimetableEntries();
    
    // Group by day
    final Map<String, List> entriesByDay = {};
    for (var entry in allEntries) {
      if (!entriesByDay.containsKey(entry.day)) {
        entriesByDay[entry.day] = [];
      }
      entriesByDay[entry.day]!.add(entry);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Text(
          'All Schedules',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        ...entriesByDay.entries.map((dayEntry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B7CFF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dayEntry.key,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${dayEntry.value.length} classes',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...dayEntry.value.map((entry) {
                final course = widget.repo.courseByCode(entry.courseCode);
                final teacher = widget.repo.teacherByInitial(entry.teacherInitial);
                final batch = widget.repo.batchById(entry.batchId);
                final room = widget.repo.roomById(entry.roomId);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF5B7CFF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B7CFF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${entry.start}\n${entry.end}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5B7CFF),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course?.title ?? entry.courseCode,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${teacher?.name ?? entry.teacherInitial} • ${batch?.name ?? entry.batchId} • ${room?.name ?? 'TBA'}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, size: 20, color: Colors.white),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditScheduleScreen(
                                  repo: widget.repo,
                                  day: entry.day,
                                  editEntry: entry,
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          } else if (value == 'delete') {
                            _confirmDeleteClass(entry);
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    final allEntries = widget.repo.getAllTimetableEntries();
    final totalClasses = allEntries.length;
    final cancelledClasses =
        allEntries.where((e) => e.isCancelled).length;
    final onlineClasses =
        allEntries.where((e) => e.mode == 'Online').length;
    final onsiteClasses =
        allEntries.where((e) => e.mode == 'Onsite').length;

    // Class distribution by day
    final classesByDay = <String, int>{};
    for (var day in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) {
      classesByDay[day] =
          allEntries.where((e) => e.day == day).length;
    }

    // Top teachers by class count
    final teacherClassCounts = <String, int>{};
    for (var entry in allEntries) {
      teacherClassCounts[entry.teacherInitial] =
          (teacherClassCounts[entry.teacherInitial] ?? 0) + 1;
    }
    final topTeachers = teacherClassCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Key Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Classes',
                  totalClasses.toString(),
                  Icons.class_,
                  const Color(0xFF5B7CFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Cancelled',
                  cancelledClasses.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Online',
                  onlineClasses.toString(),
                  Icons.language,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Onsite',
                  onsiteClasses.toString(),
                  Icons.meeting_room,
                  const Color(0xFFFFB74D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Classes by Day
          Text(
            'Classes by Day',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF5B7CFF).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: classesByDay.entries.map((e) {
                final percentage = totalClasses > 0
                    ? (e.value / totalClasses * 100).toStringAsFixed(1)
                    : '0';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          e.key,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE0E0E0),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: e.value / (totalClasses > 0 ? totalClasses : 1),
                            minHeight: 8,
                            backgroundColor: const Color(0xFF404040),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              e.value > 0
                                  ? const Color(0xFF5B7CFF)
                                  : Colors.grey[700]!,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${e.value}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5B7CFF),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Top Teachers
          Text(
            'Top Teachers by Classes',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...topTeachers.take(5).map((entry) {
            final teacher =
                widget.repo.teacherByInitial(entry.key);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8A5BFF).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8A5BFF),
                          Color(0xFF5B7CFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        entry.key,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
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
                          teacher?.name ?? 'Unknown Teacher',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          teacher?.designation ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A5BFF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${entry.value} classes',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8A5BFF),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF5B7CFF).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF5B7CFF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF5B7CFF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _showDaySelector() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Select Day',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: days.map((day) {
              return ListTile(
                title: Text(
                  day,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditScheduleScreen(
                        repo: widget.repo,
                        day: day,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteClass(dynamic entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Delete Class',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this class? This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFFE0E0E0),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[400]),
            ),
          ),
          FilledButton(
            onPressed: () async {
              await widget.repo.removeTimetableEntry(entry);
              if (context.mounted) {
                Navigator.pop(context);
              }
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Class deleted successfully',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: const Color(0xFF5B7CFF),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showBulkOperations() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Bulk Operations',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file, color: Color(0xFF5B7CFF)),
              title: Text(
                'Export Schedules',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'Download all schedules as JSON',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Export feature coming soon!',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF5B7CFF),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Color(0xFF8A5BFF)),
              title: Text(
                'Import Schedules',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'Upload schedules from JSON file',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Import feature coming soon!',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF8A5BFF),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: Text(
                'Clear All Schedules',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'Remove all schedule entries',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmClearAllSchedules();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAllSchedules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Clear All Schedules',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ALL schedules? This action cannot be undone and will remove all timetable entries.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFFE0E0E0),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[400]),
            ),
          ),
          FilledButton(
            onPressed: () async {
              // Clear all entries
              final entries = widget.repo.getAllTimetableEntries();
              for (var entry in entries) {
                await widget.repo.removeTimetableEntry(entry);
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All schedules cleared',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Clear All', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
