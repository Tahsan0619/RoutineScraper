import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../services/supabase_service.dart';
import '../models/admin.dart';
import '../models/batch.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../models/course.dart';
import '../models/room.dart';
import '../models/timetable_entry.dart';

/// Super Admin Portal with comprehensive management features
class SuperAdminPortalScreenNew extends StatefulWidget {
  const SuperAdminPortalScreenNew({super.key});

  @override
  State<SuperAdminPortalScreenNew> createState() => _SuperAdminPortalScreenNewState();
}

class _SuperAdminPortalScreenNewState extends State<SuperAdminPortalScreenNew> {
  int _selectedIndex = 0;

  final List<String> _tabTitles = [
    'Dashboard',
    'Batches',
    'Students',
    'Teachers',
    'Timetable',
    'Analytics',
  ];

  void _logout() async {
    await context.read<SupabaseService>().logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SupabaseService>();
    final admin = service.currentAdmin;

    // If logged out, return to login
    if (admin == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(admin),
            
            // Tab Bar
            _buildTabBar(),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Admin? admin) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
                  'Super Admin Portal',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  admin?.username ?? 'Admin',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabTitles.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF5B7CFF) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey[700]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _tabTitles[index],
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardTab();
      case 1:
        return _BatchesTab();
      case 2:
        return _StudentsTab();
      case 3:
        return _TeachersTab();
      case 4:
        return _TimetableTab();
      case 5:
        return _AnalyticsTab();
      default:
        return const Center(child: Text('Coming soon'));
    }
  }
}

// =====================================================
// DASHBOARD TAB
// =====================================================
class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = context.read<SupabaseService>();
    // Get the parent state to access _selectedIndex
    final parentState = context.findAncestorStateOfType<_SuperAdminPortalScreenNewState>();

    return FutureBuilder(
      future: Future.wait([
        service.getBatches(),
        service.getStudents(),
        service.getTeachers(),
        service.getAllTimetableEntries(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final batches = snapshot.data![0] as List;
        final students = snapshot.data![1] as List;
        final teachers = snapshot.data![2] as List;
        final timetable = snapshot.data![3] as List;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'System Overview',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Batches',
                      value: batches.length.toString(),
                      icon: Icons.group_work,
                      color: const Color(0xFF5B7CFF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Students',
                      value: students.length.toString(),
                      icon: Icons.school,
                      color: const Color(0xFF8A5BFF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Teachers',
                      value: teachers.length.toString(),
                      icon: Icons.person,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Classes',
                      value: timetable.length.toString(),
                      icon: Icons.calendar_today,
                      color: const Color(0xFF4ECDC4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              _QuickActionCard(
                title: 'Manage Batches',
                subtitle: 'Add, edit, or remove batches',
                icon: Icons.group_work,
                onTap: () {
                  // Switch to batches tab
                  parentState?.setState(() {
                    parentState._selectedIndex = 1;
                  });
                },
              ),
              const SizedBox(height: 8),
              _QuickActionCard(
                title: 'Manage Students',
                subtitle: 'Add students to batches',
                icon: Icons.school,
                onTap: () {
                  // Switch to students tab
                  parentState?.setState(() {
                    parentState._selectedIndex = 2;
                  });
                },
              ),
              const SizedBox(height: 8),
              _QuickActionCard(
                title: 'Manage Teachers',
                subtitle: 'View and manage teachers',
                icon: Icons.person,
                onTap: () {
                  // Switch to teachers tab
                  parentState?.setState(() {
                    parentState._selectedIndex = 3;
                  });
                },
              ),
              const SizedBox(height: 8),
              _QuickActionCard(
                title: 'Manage Timetable',
                subtitle: 'Create and modify schedules',
                icon: Icons.calendar_month,
                onTap: () {
                  // Switch to timetable tab
                  parentState?.setState(() {
                    parentState._selectedIndex = 4;
                  });
                },
              ),
              const SizedBox(height: 8),
              _QuickActionCard(
                title: 'View Analytics',
                subtitle: 'View system statistics and insights',
                icon: Icons.analytics,
                onTap: () {
                  // Switch to analytics tab
                  parentState?.setState(() {
                    parentState._selectedIndex = 5;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B7CFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF5B7CFF)),
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
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// BATCHES TAB
// =====================================================
class _BatchesTab extends StatefulWidget {
  @override
  State<_BatchesTab> createState() => _BatchesTabState();
}

class _BatchesTabState extends State<_BatchesTab> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<SupabaseService>();

    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Manage Batches',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddBatchDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Batch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7CFF),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),

        // Batches List
        Expanded(
          child: FutureBuilder<List<Batch>>(
            future: service.getBatches(forceRefresh: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }

              final batches = snapshot.data ?? [];

              if (batches.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group_work, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No batches found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _showAddBatchDialog(context),
                        child: const Text('Add Your First Batch'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: batches.length,
                itemBuilder: (context, index) {
                  final batch = batches[index];
                  return _BatchCard(
                    batch: batch,
                    onEdit: () => _showEditBatchDialog(context, batch),
                    onDelete: () => _deleteBatch(context, batch),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddBatchDialog(BuildContext context) {
    final nameController = TextEditingController();
    final sessionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Add New Batch',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Batch Name',
                hintText: 'e.g., CSE-A',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sessionController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Session',
                hintText: 'e.g., 2024-2025',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final session = sessionController.text.trim();

              if (name.isEmpty || session.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final service = context.read<SupabaseService>();
              final batch = Batch(id: '', name: name, session: session);
              final success = await service.addBatch(batch);

              if (context.mounted) {
                Navigator.pop(context);
                if (success != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Batch added successfully')),
                  );
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add batch')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditBatchDialog(BuildContext context, Batch batch) {
    final nameController = TextEditingController(text: batch.name);
    final sessionController = TextEditingController(text: batch.session);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Edit Batch',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Batch Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sessionController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Session'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedBatch = Batch(
                id: batch.id,
                name: nameController.text.trim(),
                session: sessionController.text.trim(),
              );

              final service = context.read<SupabaseService>();
              final success = await service.updateBatch(batch.id, updatedBatch);

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Batch updated successfully')),
                  );
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update batch')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteBatch(BuildContext context, Batch batch) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Delete Batch?', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${batch.name}?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final service = context.read<SupabaseService>();
      final success = await service.deleteBatch(batch.id);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Batch deleted successfully')),
          );
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete batch')),
          );
        }
      }
    }
  }
}

class _BatchCard extends StatelessWidget {
  final Batch batch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BatchCard({
    required this.batch,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF5B7CFF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.group_work, color: Color(0xFF5B7CFF)),
        ),
        title: Text(
          batch.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          batch.session,
          style: GoogleFonts.poppins(color: Colors.grey[400]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF5B7CFF)),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// STUDENTS TAB
// =====================================================
class _StudentsTab extends StatefulWidget {
  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  String? _selectedBatchId;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SupabaseService>();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Manage Students',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddStudentDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Student'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7CFF),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),

        // Batch Filter
        FutureBuilder<List<Batch>>(
          future: service.getBatches(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            final batches = snapshot.data!;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: _selectedBatchId,
                decoration: InputDecoration(
                  labelText: 'Filter by Batch',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                ),
                dropdownColor: const Color(0xFF2A2A2A),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'All Batches',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                  ...batches.map((batch) => DropdownMenuItem<String>(
                        value: batch.id,
                        child: Text(
                          batch.name,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedBatchId = value);
                },
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Students List
        Expanded(
          child: FutureBuilder<List<Student>>(
            future: _selectedBatchId == null
                ? service.getStudents(forceRefresh: true)
                : service.getStudentsByBatchId(_selectedBatchId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }

              final students = snapshot.data ?? [];

              if (students.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No students found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _showAddStudentDialog(context),
                        child: const Text('Add Your First Student'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return _StudentCard(
                    student: student,
                    onEdit: () => _showEditStudentDialog(context, student),
                    onDelete: () => _deleteStudent(context, student),
                    onManageCredentials: _showManageStudentCredentialsDialog,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final studentIdController = TextEditingController();
    final nameController = TextEditingController();
    String? selectedBatchId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Add New Student',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: studentIdController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    hintText: 'e.g., 2023-CSE-001',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    hintText: 'e.g., John Doe',
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Batch>>(
                  future: context.read<SupabaseService>().getBatches(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final batches = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: selectedBatchId,
                      decoration: const InputDecoration(labelText: 'Batch'),
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: batches.map((batch) => DropdownMenuItem<String>(
                            value: batch.id,
                            child: Text(
                              batch.name,
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          )).toList(),
                      onChanged: (value) {
                        setState(() => selectedBatchId = value);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final studentId = studentIdController.text.trim();
                final name = nameController.text.trim();

                if (studentId.isEmpty || name.isEmpty || selectedBatchId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final service = context.read<SupabaseService>();
                final student = Student(
                  studentId: studentId,
                  name: name,
                  batchId: selectedBatchId!,
                );
                final success = await service.addStudent(student);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Student added successfully')),
                    );
                    this.setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add student')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, Student student) {
    final nameController = TextEditingController(text: student.name);
    String? selectedBatchId = student.batchId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Edit Student',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Student ID: ${student.studentId}',
                  style: GoogleFonts.poppins(color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Student Name'),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Batch>>(
                  future: context.read<SupabaseService>().getBatches(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final batches = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: selectedBatchId,
                      decoration: const InputDecoration(labelText: 'Batch'),
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: batches.map((batch) => DropdownMenuItem<String>(
                            value: batch.id,
                            child: Text(
                              batch.name,
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          )).toList(),
                      onChanged: (value) {
                        setState(() => selectedBatchId = value);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedStudent = Student(
                  studentId: student.studentId,
                  name: nameController.text.trim(),
                  batchId: selectedBatchId!,
                );

                final service = context.read<SupabaseService>();
                final success = await service.updateStudent(
                  student.studentId,
                  updatedStudent,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Student updated successfully')),
                    );
                    this.setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update student')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteStudent(BuildContext context, Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Delete Student?', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${student.name}?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final service = context.read<SupabaseService>();
      final success = await service.deleteStudent(student.studentId);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student deleted successfully')),
          );
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete student')),
          );
        }
      }
    }
  }
  void _showManageStudentCredentialsDialog(BuildContext context, Student student) async {
    final passwordController = TextEditingController();
    bool _showPassword = false;

    // Fetch latest student data from database to get updated has_changed_password flag
    final service = context.read<SupabaseService>();
    final updatedStudent = await service.getStudentById(student.studentId);
    final studentToShow = updatedStudent ?? student;
    
    final emailController = TextEditingController(text: studentToShow.email ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Set Login Credentials: ${studentToShow.name}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (studentToShow.hasChangedPassword)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This student has changed their password. Credentials are locked and cannot be modified.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.red[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  TextField(
                    controller: emailController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Initial Password',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey[600],
                        ),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Once the student changes their password, you won\'t be able to see it anymore.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.amber[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (!studentToShow.hasChangedPassword)
              ElevatedButton(
                onPressed: () async {
                  if (passwordController.text.isEmpty || emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  final service = context.read<SupabaseService>();
                  try {
                    await service.setStudentCredentials(
                      studentToShow.studentId,
                      emailController.text.trim(),
                      passwordController.text,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Credentials set successfully')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7CFF),
                ),
                child: const Text('Set Credentials'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(BuildContext, Student)? onManageCredentials;

  const _StudentCard({
    required this.student,
    required this.onEdit,
    required this.onDelete,
    this.onManageCredentials,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF8A5BFF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.school, color: Color(0xFF8A5BFF)),
        ),
        title: Text(
          student.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          student.studentId,
          style: GoogleFonts.poppins(color: Colors.grey[400]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onManageCredentials != null)
              IconButton(
                icon: const Icon(Icons.vpn_key, color: Color(0xFF8A5BFF)),
                onPressed: () => onManageCredentials!(context, student),
                tooltip: 'Manage Login Credentials',
              ),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF5B7CFF)),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// TEACHERS TAB
// =====================================================
class _TeachersTab extends StatefulWidget {
  @override
  State<_TeachersTab> createState() => _TeachersTabState();
}

class _TeachersTabState extends State<_TeachersTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SupabaseService>();

    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Manage Teachers',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddTeacherDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Teacher'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7CFF),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Search teachers...',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF5B7CFF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Teachers List
        Expanded(
          child: FutureBuilder<List<Teacher>>(
            future: service.getTeachers(forceRefresh: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }

              var teachers = snapshot.data ?? [];

              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                teachers = teachers.where((teacher) {
                  final query = _searchQuery.toLowerCase();
                  return teacher.name.toLowerCase().contains(query) ||
                      teacher.initial.toLowerCase().contains(query) ||
                      teacher.email.toLowerCase().contains(query) ||
                      teacher.designation.toLowerCase().contains(query);
                }).toList();
              }

              if (teachers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty ? 'No teachers found' : 'No matching teachers',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _showAddTeacherDialog(context),
                          child: const Text('Add Your First Teacher'),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: teachers.length,
                itemBuilder: (context, index) {
                  final teacher = teachers[index];
                  return _TeacherCard(
                    teacher: teacher,
                    onEdit: () => _showEditTeacherDialog(context, teacher),
                    onDelete: () => _deleteTeacher(context, teacher),
                    onManageCredentials: _showManageTeacherCredentialsDialog,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddTeacherDialog(BuildContext context) {
    final nameController = TextEditingController();
    final initialController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final designationController = TextEditingController();
    final homeDepartmentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Add New Teacher',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'e.g., Dr. John Doe',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: initialController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Initial *',
                  hintText: 'e.g., JD',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: GoogleFonts.poppins(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  hintText: 'e.g., john.doe@university.edu',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                style: GoogleFonts.poppins(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone *',
                  hintText: 'e.g., +1234567890',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: designationController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Designation *',
                  hintText: 'e.g., Professor',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: homeDepartmentController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Home Department *',
                  hintText: 'e.g., Computer Science',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final initial = initialController.text.trim();
              final email = emailController.text.trim();
              final phone = phoneController.text.trim();
              final designation = designationController.text.trim();
              final homeDepartment = homeDepartmentController.text.trim();

              if (name.isEmpty || initial.isEmpty || email.isEmpty || 
                  phone.isEmpty || designation.isEmpty || homeDepartment.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final service = context.read<SupabaseService>();
              final teacher = Teacher(
                id: '',
                initial: initial,
                name: name,
                email: email,
                phone: phone,
                designation: designation,
                homeDepartment: homeDepartment,
              );
              final success = await service.addTeacher(teacher);

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teacher added successfully')),
                  );
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add teacher')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditTeacherDialog(BuildContext context, Teacher teacher) {
    final nameController = TextEditingController(text: teacher.name);
    final emailController = TextEditingController(text: teacher.email);
    final phoneController = TextEditingController(text: teacher.phone);
    final designationController = TextEditingController(text: teacher.designation);
    final homeDepartmentController = TextEditingController(text: teacher.homeDepartment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Edit Teacher',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Initial: ${teacher.initial}',
                style: GoogleFonts.poppins(color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),
              // Profile Picture Display (Read-only)
              if (teacher.profilePic != null && teacher.profilePic!.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Picture (managed by teacher)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          teacher.profilePic!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: Colors.grey[800],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: nameController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: GoogleFonts.poppins(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                style: GoogleFonts.poppins(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: designationController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Designation'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: homeDepartmentController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Home Department'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedTeacher = Teacher(
                id: teacher.id,
                initial: teacher.initial,
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
                designation: designationController.text.trim(),
                homeDepartment: homeDepartmentController.text.trim(),
              );

              final service = context.read<SupabaseService>();
              final success = await service.updateTeacher(
                teacher.initial,
                updatedTeacher,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teacher updated successfully')),
                  );
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update teacher')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteTeacher(BuildContext context, Teacher teacher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Delete Teacher?', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${teacher.name}?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final service = context.read<SupabaseService>();
      final success = await service.deleteTeacher(teacher.initial);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Teacher deleted successfully')),
          );
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete teacher')),
          );
        }
      }
    }
  }

  void _showManageTeacherCredentialsDialog(BuildContext context, Teacher teacher) async {
    final passwordController = TextEditingController();
    bool _showPassword = false;

    // Fetch latest teacher data from database to get updated has_changed_password flag
    final service = context.read<SupabaseService>();
    final updatedTeacher = await service.getTeacherById(teacher.id);
    final teacherToShow = updatedTeacher ?? teacher;
    
    final emailController = TextEditingController(text: teacherToShow.email);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Set Login Credentials: ${teacherToShow.name}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (teacherToShow.hasChangedPassword)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This teacher has changed their password. Credentials are locked and cannot be modified.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.red[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  TextField(
                    controller: emailController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Initial Password',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey[600],
                        ),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Once the teacher changes their password, you won\'t be able to see it anymore.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.amber[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (!teacherToShow.hasChangedPassword)
              ElevatedButton(
                onPressed: () async {
                  if (passwordController.text.isEmpty || emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  final service = context.read<SupabaseService>();
                  try {
                    await service.setTeacherCredentials(
                      teacherToShow.id,
                      emailController.text.trim(),
                      passwordController.text,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Credentials set successfully')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7CFF),
                ),
                child: const Text('Set Credentials'),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(BuildContext, Teacher)? onManageCredentials;

  const _TeacherCard({
    required this.teacher,
    required this.onEdit,
    required this.onDelete,
    this.onManageCredentials,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile Picture or Initial Avatar
                teacher.profilePic != null && teacher.profilePic!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          teacher.profilePic!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildInitialAvatar();
                          },
                        ),
                      )
                    : _buildInitialAvatar(),
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
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF5B7CFF)),
                  onPressed: onEdit,
                ),
                if (onManageCredentials != null)
                  IconButton(
                    icon: const Icon(Icons.vpn_key, color: Color(0xFF8A5BFF)),
                    onPressed: () => onManageCredentials!(context, teacher),
                    tooltip: 'Manage Login Credentials',
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey[800]),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Color(0xFF5B7CFF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    teacher.email,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Color(0xFF5B7CFF)),
                const SizedBox(width: 8),
                Text(
                  teacher.phone,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.business, size: 16, color: Color(0xFF5B7CFF)),
                const SizedBox(width: 8),
                Text(
                  teacher.homeDepartment,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          teacher.initial,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// TIMETABLE TAB
// =====================================================
class _TimetableTab extends StatefulWidget {
  @override
  State<_TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<_TimetableTab> {
  String _selectedDay = 'Mon';
  final List<String> _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SupabaseService>();

    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Timetable',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddTimetableDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Class'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7CFF),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _exportTimetableToPDF(context),
                      icon: const Icon(Icons.file_download, size: 18),
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _importTimetable(context),
                      icon: const Icon(Icons.file_upload, size: 18),
                      label: const Text('Import'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Day Selector
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            itemBuilder: (context, index) {
              final day = _days[index];
              final isSelected = day == _selectedDay;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDay = day);
                  },
                  selectedColor: const Color(0xFF5B7CFF),
                  labelStyle: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Timetable Entries List
        Expanded(
          child: FutureBuilder<List<TimetableEntry>>(
            future: service.getAllTimetableEntries(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }

              final allEntries = snapshot.data ?? [];
              final dayEntries = allEntries
                  .where((entry) => entry.day == _selectedDay)
                  .toList()
                ..sort((a, b) => a.start.compareTo(b.start));

              if (dayEntries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No classes scheduled for $_selectedDay',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _showAddTimetableDialog(context),
                        child: const Text('Add a Class'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: dayEntries.length,
                itemBuilder: (context, index) {
                  final entry = dayEntries[index];
                  return _TimetableEntryCard(
                    entry: entry,
                    onEdit: () => _showEditTimetableDialog(context, entry),
                    onDelete: () => _deleteTimetableEntry(context, entry),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddTimetableDialog(BuildContext context) {
    final service = context.read<SupabaseService>();
    
    String? selectedBatchId;
    String? selectedTeacherInitial;
    String? selectedCourseCode;
    String? selectedType;
    String? selectedMode;
    String? selectedRoomId;
    String? selectedGroup = 'None';
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    final types = ['Lecture', 'Tutorial', 'Sessional', 'Online'];
    final modes = ['Onsite', 'Online'];
    final groups = ['None', 'G-1', 'G-2'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Add New Class',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Day selector
                DropdownButtonFormField<String>(
                  value: _selectedDay,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Day'),
                  dropdownColor: const Color(0xFF2A2A2A),
                  items: _days.map((day) => DropdownMenuItem(
                        value: day,
                        child: Text(day, style: GoogleFonts.poppins(color: Colors.white)),
                      )).toList(),
                  onChanged: (value) {
                    setState(() => _selectedDay = value!);
                  },
                ),
                const SizedBox(height: 16),

                // Batch selector
                FutureBuilder<List<Batch>>(
                  future: service.getBatches(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final batches = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: selectedBatchId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Batch *'),
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: batches.map((batch) => DropdownMenuItem(
                            value: batch.id,
                            child: Text(
                              '${batch.name} (${batch.session})',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          )).toList(),
                      onChanged: (value) {
                        setState(() => selectedBatchId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Teacher selector
                FutureBuilder<List<Teacher>>(
                  future: service.getTeachers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final teachers = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: selectedTeacherInitial,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Teacher *'),
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: teachers.map((teacher) => DropdownMenuItem(
                            value: teacher.initial,
                            child: Text(
                              '${teacher.name} (${teacher.initial})',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          )).toList(),
                      onChanged: (value) {
                        setState(() => selectedTeacherInitial = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Course selector
                FutureBuilder<List<Course>>(
                  future: service.getCourses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final courses = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: selectedCourseCode,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Course *'),
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: courses.map((course) => DropdownMenuItem(
                            value: course.code,
                            child: Text(
                              '${course.code} - ${course.title}',
                              style: GoogleFonts.poppins(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )).toList(),
                      onChanged: (value) {
                        setState(() => selectedCourseCode = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Type selector
                DropdownButtonFormField<String>(
                  value: selectedType,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Type *'),
                  dropdownColor: const Color(0xFF2A2A2A),
                  items: types.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type, style: GoogleFonts.poppins(color: Colors.white)),
                      )).toList(),
                  onChanged: (value) {
                    setState(() => selectedType = value);
                  },
                ),
                const SizedBox(height: 16),

                // Mode selector
                DropdownButtonFormField<String>(
                  value: selectedMode,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Mode *'),
                  dropdownColor: const Color(0xFF2A2A2A),
                  items: modes.map((mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode, style: GoogleFonts.poppins(color: Colors.white)),
                      )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMode = value;
                      if (value == 'Online') selectedRoomId = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Room selector (if Onsite)
                if (selectedMode == 'Onsite')
                  FutureBuilder<List<Room>>(
                    future: service.getRooms(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final rooms = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        value: selectedRoomId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Room'),
                        dropdownColor: const Color(0xFF2A2A2A),
                        items: rooms.map((room) => DropdownMenuItem(
                              value: room.id,
                              child: Text(room.name, style: GoogleFonts.poppins(color: Colors.white)),
                            )).toList(),
                        onChanged: (value) {
                          setState(() => selectedRoomId = value);
                        },
                      );
                    },
                  ),
                const SizedBox(height: 16),

                // Group selector
                DropdownButtonFormField<String>(
                  value: selectedGroup,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Group'),
                  dropdownColor: const Color(0xFF2A2A2A),
                  items: groups.map((group) => DropdownMenuItem(
                        value: group,
                        child: Text(group, style: GoogleFonts.poppins(color: Colors.white)),
                      )).toList(),
                  onChanged: (value) {
                    setState(() => selectedGroup = value);
                  },
                ),
                const SizedBox(height: 16),

                // Time pickers
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: startTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() => startTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(startTime == null
                            ? 'Start Time *'
                            : '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: endTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() => endTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(endTime == null
                            ? 'End Time *'
                            : '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedBatchId == null || selectedTeacherInitial == null ||
                    selectedCourseCode == null || selectedType == null ||
                    selectedMode == null || startTime == null || endTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final entry = TimetableEntry(
                  day: _selectedDay,
                  batchId: selectedBatchId!,
                  teacherInitial: selectedTeacherInitial!,
                  courseCode: selectedCourseCode!,
                  type: selectedType!,
                  mode: selectedMode!,
                  roomId: selectedMode == 'Online' ? null : selectedRoomId,
                  group: selectedGroup == 'None' ? null : selectedGroup,
                  start: '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                  end: '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                );

                final success = await service.addTimetableEntry(entry);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Class added successfully')),
                    );
                    this.setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add class')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTimetableDialog(BuildContext context, TimetableEntry entry) async {
    final service = context.read<SupabaseService>();
    
    // Get the entry ID
    final entryId = await service.getTimetableEntryId(entry);
    if (entryId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find entry ID')),
        );
      }
      return;
    }

    String selectedDay = entry.day;
    String? selectedBatchId = entry.batchId;
    String? selectedTeacherInitial = entry.teacherInitial;
    String? selectedCourseCode = entry.courseCode;
    String? selectedType = entry.type;
    String? selectedMode = entry.mode;
    String? selectedRoomId = entry.roomId;
    String? selectedGroup = entry.group ?? 'None';
    
    final startParts = entry.start.split(':');
    TimeOfDay? startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );
    final endParts = entry.end.split(':');
    TimeOfDay? endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );

    final types = ['Lecture', 'Tutorial', 'Sessional', 'Online'];
    final modes = ['Onsite', 'Online'];
    final groups = ['None', 'G-1', 'G-2'];

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Edit Class',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Day selector
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Day'),
                  dropdownColor: const Color(0xFF2A2A2A),
                  items: _days.map((day) => DropdownMenuItem(
                        value: day,
                        child: Text(day, style: GoogleFonts.poppins(color: Colors.white)),
                      )).toList(),
                  onChanged: (value) {
                    setState(() => selectedDay = value!);
                  },
                ),
                const SizedBox(height: 16),

                // Batch selector
                FutureBuilder<List<Batch>>(
                  future: service.getBatches(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final batches = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: selectedBatchId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Batch *'),
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: batches.map((batch) => DropdownMenuItem(
                            value: batch.id,
                            child: Text(
                              '${batch.name} (${batch.session})',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          )).toList(),
                      onChanged: (value) {
                        setState(() => selectedBatchId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Teacher selector
                FutureBuilder<List<Teacher>>(
                  future: service.getTeachers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final teachers = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: selectedTeacherInitial,
                      decoration: const InputDecoration(labelText: 'Teacher *'),
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: teachers.map((teacher) => DropdownMenuItem(
                            value: teacher.initial,
                            child: Text(
                              '${teacher.name} (${teacher.initial})',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          )).toList(),
                      onChanged: (value) {
                        setState(() => selectedTeacherInitial = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Course selector
                FutureBuilder<List<Course>>(
                  future: service.getCourses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final courses = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: selectedCourseCode,
                      decoration: const InputDecoration(labelText: 'Course *'),
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: courses.map((course) => DropdownMenuItem(
                            value: course.code,
                            child: Text(
                              '${course.code} - ${course.title}',
                              style: GoogleFonts.poppins(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )).toList(),
                      onChanged: (value) {
                        setState(() => selectedCourseCode = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Type selector
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type *'),
                  dropdownColor: const Color(0xFF2A2A2A),
                  items: types.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type, style: GoogleFonts.poppins(color: Colors.white)),
                      )).toList(),
                  onChanged: (value) {
                    setState(() => selectedType = value);
                  },
                ),
                const SizedBox(height: 16),

                // Mode selector
                DropdownButtonFormField<String>(
                  value: selectedMode,
                  decoration: const InputDecoration(labelText: 'Mode *'),
                  dropdownColor: const Color(0xFF2A2A2A),
                  items: modes.map((mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode, style: GoogleFonts.poppins(color: Colors.white)),
                      )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMode = value;
                      if (value == 'Online') selectedRoomId = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Room selector (if Onsite)
                if (selectedMode == 'Onsite')
                  FutureBuilder<List<Room>>(
                    future: service.getRooms(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final rooms = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        value: selectedRoomId,
                        decoration: const InputDecoration(labelText: 'Room'),
                        dropdownColor: const Color(0xFF2A2A2A),
                        items: rooms.map((room) => DropdownMenuItem(
                              value: room.id,
                              child: Text(room.name, style: GoogleFonts.poppins(color: Colors.white)),
                            )).toList(),
                        onChanged: (value) {
                          setState(() => selectedRoomId = value);
                        },
                      );
                    },
                  ),
                const SizedBox(height: 16),

                // Group selector
                DropdownButtonFormField<String>(
                  value: selectedGroup,
                  decoration: const InputDecoration(labelText: 'Group'),
                  dropdownColor: const Color(0xFF2A2A2A),
                  items: groups.map((group) => DropdownMenuItem(
                        value: group,
                        child: Text(group, style: GoogleFonts.poppins(color: Colors.white)),
                      )).toList(),
                  onChanged: (value) {
                    setState(() => selectedGroup = value);
                  },
                ),
                const SizedBox(height: 16),

                // Time pickers
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: startTime!,
                          );
                          if (time != null) {
                            setState(() => startTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: endTime!,
                          );
                          if (time != null) {
                            setState(() => endTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedEntry = TimetableEntry(
                  day: selectedDay,
                  batchId: selectedBatchId!,
                  teacherInitial: selectedTeacherInitial!,
                  courseCode: selectedCourseCode!,
                  type: selectedType!,
                  mode: selectedMode!,
                  roomId: selectedMode == 'Online' ? null : selectedRoomId,
                  group: selectedGroup == 'None' ? null : selectedGroup,
                  start: '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
                  end: '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
                );

                final success = await service.updateTimetableEntry(entryId, updatedEntry);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Class updated successfully')),
                    );
                    this.setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update class')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTimetableEntry(BuildContext context, TimetableEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Delete Class?', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this class?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final service = context.read<SupabaseService>();
      
      // Get the entry ID
      final entryId = await service.getTimetableEntryId(entry);
      if (entryId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not find entry ID')),
          );
        }
        return;
      }

      final success = await service.deleteTimetableEntry(entryId);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class deleted successfully')),
          );
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete class')),
          );
        }
      }
    }
  }

  Future<void> _exportTimetableToPDF(BuildContext context) async {
    final service = context.read<SupabaseService>();
    
    try {
      final entries = await service.getAllTimetableEntries();
      final timetableEntries = (entries as List)
          .map((e) => TimetableEntry.fromJson(e))
          .toList();

      final pdf = pw.Document();

      // Create PDF with all timetable entries
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Class Timetable',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on: ${DateTime.now().toString().split('.')[0]}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 20),
            ..._buildTimetablePDF(timetableEntries),
          ],
        ),
      );

      // Save and share PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'timetable_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timetable exported successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting PDF: $e')),
        );
      }
    }
  }

  List<pw.Widget> _buildTimetablePDF(List<TimetableEntry> entries) {
    final dayEntries = <String, List<TimetableEntry>>{};
    
    for (var entry in entries) {
      if (!dayEntries.containsKey(entry.day)) {
        dayEntries[entry.day] = [];
      }
      dayEntries[entry.day]!.add(entry);
    }

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final widgets = <pw.Widget>[];

    for (var day in days) {
      if (dayEntries[day]?.isNotEmpty ?? false) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  day,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  children: [
                    // Header row
                    pw.TableRow(
                      children: [
                        _buildPDFTableCell('Batch', bold: true),
                        _buildPDFTableCell('Course', bold: true),
                        _buildPDFTableCell('Type', bold: true),
                        _buildPDFTableCell('Time', bold: true),
                        _buildPDFTableCell('Mode', bold: true),
                        _buildPDFTableCell('Teacher', bold: true),
                      ],
                    ),
                    // Data rows
                    ...dayEntries[day]!.map((entry) => pw.TableRow(
                      children: [
                        _buildPDFTableCell(entry.batchId),
                        _buildPDFTableCell(entry.courseCode),
                        _buildPDFTableCell(entry.type),
                        _buildPDFTableCell('${entry.start} - ${entry.end}'),
                        _buildPDFTableCell(entry.mode),
                        _buildPDFTableCell(entry.teacherInitial),
                      ],
                    )).toList(),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  pw.Widget _buildPDFTableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _importTimetable(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final content = await file.readAsString();

        if (result.files.first.extension == 'json') {
          await _importFromJSON(context, content);
        } else if (result.files.first.extension == 'csv') {
          await _importFromCSV(context, content);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing file: $e')),
        );
      }
    }
  }

  Future<void> _importFromJSON(BuildContext context, String content) async {
    try {
      final service = context.read<SupabaseService>();
      final json = jsonDecode(content);
      
      List<dynamic> entries = [];
      if (json is List) {
        entries = json;
      } else if (json is Map && json.containsKey('entries')) {
        entries = json['entries'] as List;
      }

      if (entries.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No entries found in JSON file')),
          );
        }
        return;
      }

      // Show confirmation dialog
      if (context.mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              'Import Timetable',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            content: Text(
              'Found ${entries.length} entries. Do you want to add them to the timetable?\n\nNote: This will add these entries to existing data.',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Import'),
              ),
            ],
          ),
        );

        if (confirm != true) return;
      }

      int successCount = 0;
      int failCount = 0;

      for (var entry in entries) {
        try {
          final timetableEntry = TimetableEntry.fromJson(entry as Map<String, dynamic>);
          await service.addTimetableEntry(timetableEntry);
          successCount++;
        } catch (e) {
          failCount++;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported: $successCount | Failed: $failCount'),
            backgroundColor: failCount == 0 ? Colors.green : Colors.orange,
          ),
        );
        // Refresh the timetable view
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing JSON: $e')),
        );
      }
    }
  }

  Future<void> _importFromCSV(BuildContext context, String content) async {
    try {
      final service = context.read<SupabaseService>();
      final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      if (lines.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CSV file is empty')),
          );
        }
        return;
      }

      // Skip header row
      final entries = lines.skip(1).toList();

      if (entries.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data rows in CSV')),
          );
        }
        return;
      }

      // Show confirmation dialog
      if (context.mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              'Import Timetable',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            content: Text(
              'Found ${entries.length} entries. Do you want to add them to the timetable?\n\nExpected CSV format:\nday,batchId,teacherInitial,courseCode,type,mode,start,end,roomId',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Import'),
              ),
            ],
          ),
        );

        if (confirm != true) return;
      }

      int successCount = 0;
      int failCount = 0;

      for (var line in entries) {
        try {
          final parts = line.split(',').map((s) => s.trim()).toList();
          if (parts.length < 8) continue;

          final timetableEntry = TimetableEntry(
            day: parts[0],
            batchId: parts[1],
            teacherInitial: parts[2],
            courseCode: parts[3],
            type: parts[4],
            mode: parts[5],
            start: parts[6],
            end: parts[7],
            roomId: parts.length > 8 ? parts[8] : null,
          );

          await service.addTimetableEntry(timetableEntry);
          successCount++;
        } catch (e) {
          failCount++;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported: $successCount | Failed: $failCount'),
            backgroundColor: failCount == 0 ? Colors.green : Colors.orange,
          ),
        );
        // Refresh the timetable view
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing CSV: $e')),
        );
      }
    }
  }
}

class _TimetableEntryCard extends StatelessWidget {
  final TimetableEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TimetableEntryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.read<SupabaseService>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${entry.start} - ${entry.end}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF5B7CFF), size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Course info
            FutureBuilder<Course?>(
              future: service.getCourseByCode(entry.courseCode),
              builder: (context, snapshot) {
                final course = snapshot.data;
                return Text(
                  course?.title ?? entry.courseCode,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              entry.courseCode,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 12),
            
            // Details
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _DetailChip(
                  icon: Icons.person,
                  label: entry.teacherInitial,
                  color: const Color(0xFFFF6B6B),
                ),
                _DetailChip(
                  icon: Icons.group_work,
                  label: entry.batchId,
                  color: const Color(0xFF5B7CFF),
                ),
                _DetailChip(
                  icon: Icons.class_,
                  label: entry.type,
                  color: const Color(0xFF8A5BFF),
                ),
                if (entry.mode == 'Online')
                  _DetailChip(
                    icon: Icons.wifi,
                    label: 'Online',
                    color: const Color(0xFF4ECDC4),
                  )
                else if (entry.roomId != null)
                  _DetailChip(
                    icon: Icons.room,
                    label: entry.roomId!,
                    color: const Color(0xFFFFA726),
                  ),
                if (entry.group != null)
                  _DetailChip(
                    icon: Icons.people,
                    label: entry.group!,
                    color: const Color(0xFFAB47BC),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ANALYTICS TAB
// =====================================================
class _AnalyticsTab extends StatefulWidget {
  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab> {
  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();
    
    return FutureBuilder(
      future: Future.wait([
        service.getAllTimetableEntries(),
        service.getBatches(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final entries = snapshot.data![0] as List<TimetableEntry>;
        final batches = snapshot.data![1] as List<Batch>;
        final batchNameMap = <String, String>{};
        for (var batch in batches) {
          batchNameMap[batch.id] = '${batch.name} (${batch.session})';
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 20 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Dashboard',
                    style: GoogleFonts.poppins(
                      fontSize: isWide ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Key Metrics Row - responsive wrap
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricCard(
                        title: 'Total Classes',
                        value: entries.length.toString(),
                        icon: Icons.school,
                        color: Colors.blue,
                        isCompact: !isWide,
                      ),
                      _MetricCard(
                        title: 'Online Classes',
                        value: entries
                            .where((e) => e.mode.toLowerCase() == 'online')
                            .length
                            .toString(),
                        icon: Icons.videocam,
                        color: Colors.green,
                        isCompact: !isWide,
                      ),
                      _MetricCard(
                        title: 'Onsite Classes',
                        value: entries
                            .where((e) => e.mode.toLowerCase() == 'onsite')
                            .length
                            .toString(),
                        icon: Icons.location_on,
                        color: Colors.orange,
                        isCompact: !isWide,
                      ),
                      _MetricCard(
                        title: 'Cancelled',
                        value: entries
                            .where((e) => e.isCancelled == true)
                            .length
                            .toString(),
                        icon: Icons.cancel,
                        color: Colors.red,
                        isCompact: !isWide,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Classes by Batch
                  _buildClassesByBatch(entries, batchNameMap),
                  const SizedBox(height: 30),

                  // Classes by Day
                  _buildClassesByDay(entries, isWide),
                  const SizedBox(height: 30),

                  // Classes by Type
                  _buildClassesByType(entries, isWide),
                  const SizedBox(height: 30),

                  // Classes by Mode
                  _buildClassesByMode(entries),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClassesByBatch(List<TimetableEntry> entries, Map<String, String> batchNameMap) {
    final batchMap = <String, int>{};
    
    for (var entry in entries) {
      if (entry.batchId.isNotEmpty) {
        batchMap[entry.batchId] = (batchMap[entry.batchId] ?? 0) + 1;
      }
    }

    final sortedBatches = batchMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Classes by Batch',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (sortedBatches.isEmpty)
            const Text('No data available')
          else
            ...sortedBatches.map((entry) {
              final percentage = (entry.value / entries.length * 100).toStringAsFixed(1);
              final batchName = batchNameMap[entry.key] ?? entry.key;
              final fraction = entry.value / entries.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            batchName,
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value} ($percentage%)',
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildClassesByDay(List<TimetableEntry> entries, bool isWide) {
    final dayMap = <String, int>{};
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (var day in days) {
      dayMap[day] = 0;
    }

    for (var entry in entries) {
      if (dayMap.containsKey(entry.day)) {
        dayMap[entry.day] = (dayMap[entry.day] ?? 0) + 1;
      }
    }

    final maxCount = dayMap.values.fold(0, (a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Classes Distribution by Day',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: isWide ? 12 : 6,
            runSpacing: 12,
            children: dayMap.entries.map((entry) {
              final barHeight = maxCount > 0 ? (entry.value / maxCount * 100).clamp(8.0, 100.0) : 8.0;
              return SizedBox(
                width: isWide ? 50 : 38,
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: isWide ? 36 : 28,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: _getColorForCount(entry.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              entry.value.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: isWide ? 14 : 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.key.substring(0, 3),
                      style: GoogleFonts.poppins(fontSize: isWide ? 12 : 10),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesByType(List<TimetableEntry> entries, bool isWide) {
    final typeMap = <String, int>{};
    
    for (var entry in entries) {
      if (entry.type.isNotEmpty) {
        typeMap[entry.type] = (typeMap[entry.type] ?? 0) + 1;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Classes by Type',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: typeMap.entries.map((entry) {
              final percentage = (entry.value / entries.length * 100).toStringAsFixed(1);
              return Container(
                width: isWide ? null : double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTypeColor(entry.key),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isWide
                    ? Column(
                        children: [
                          Text(
                            entry.key,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.value.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$percentage%',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${entry.value} ($percentage%)',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesByMode(List<TimetableEntry> entries) {
    final modeStatus = <String, Map<String, int>>{};
    
    for (var entry in entries) {
      if (!modeStatus.containsKey(entry.mode)) {
        modeStatus[entry.mode] = {
          'total': 0,
          'cancelled': 0,
        };
      }
      
      modeStatus[entry.mode]!['total'] = (modeStatus[entry.mode]!['total'] ?? 0) + 1;
      if (entry.isCancelled) {
        modeStatus[entry.mode]!['cancelled'] = (modeStatus[entry.mode]!['cancelled'] ?? 0) + 1;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Classes by Mode',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (modeStatus.isEmpty)
            const Text('No data available')
          else
            ...modeStatus.entries.map((entry) {
              final total = entry.value['total'] ?? 0;
              final cancelled = entry.value['cancelled'] ?? 0;
              final active = total - cancelled;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _ModeChip(label: 'Total', value: total, color: Colors.blue),
                          const SizedBox(width: 8),
                          _ModeChip(label: 'Active', value: active, color: Colors.green),
                          const SizedBox(width: 8),
                          _ModeChip(label: 'Cancelled', value: cancelled, color: Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _getColorForCount(int count) {
    if (count == 0) return Colors.grey.shade300;
    if (count < 5) return Colors.blue.shade300;
    if (count < 10) return Colors.blue.shade500;
    return Colors.blue.shade700;
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'lecture':
        return Colors.purple;
      case 'tutorial':
        return Colors.teal;
      case 'sessional':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

// Metric Card Widget
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isCompact;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 150 : 180,
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 11 : 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: isCompact ? 18 : 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isCompact ? 22 : 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Mode Chip Widget
class _ModeChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ModeChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
