import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/data_repository.dart';
import '../services/supabase_service.dart';
import '../models/admin.dart';
import '../models/timetable_entry.dart';
import '../widgets/online_badge.dart';
import 'teacher_profile_screen.dart';

/// Teacher admin portal for managing own classes with dark theme
class TeacherAdminPortalScreen extends StatefulWidget {
  final DataRepository repo;
  final Admin admin;

  const TeacherAdminPortalScreen({
    super.key,
    required this.repo,
    required this.admin,
  });

  @override
  State<TeacherAdminPortalScreen> createState() =>
      _TeacherAdminPortalScreenState();
}

class _TeacherAdminPortalScreenState extends State<TeacherAdminPortalScreen> {
  String selectedDay = 'Sun';
  final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  void _logout() async {
    await context.read<SupabaseService>().logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _cancelClass(TimetableEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        final reasonController = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Cancel Class',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: TextField(
            controller: reasonController,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Reason for cancellation',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () async {
                await widget.repo.cancelClass(entry, reasonController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                }
                setState(() {});
              },
              child: Text('Confirm', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _changeRoom(TimetableEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedRoomId;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: Text(
                'Change Room',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              content: DropdownButtonFormField<String>(
                value: selectedRoomId,
                dropdownColor: const Color(0xFF2A2A2A),
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Select Room',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                items: widget.repo.data!.rooms.map((room) {
                  return DropdownMenuItem(
                    value: room.id,
                    child: Text(room.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedRoomId = value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedRoomId != null) {
                      await widget.repo.changeRoom(entry, selectedRoomId!);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      setState(() {});
                    }
                  },
                  child: Text('Confirm', style: GoogleFonts.poppins()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _rescheduleClass(TimetableEntry entry) {
    final startController = TextEditingController(text: entry.start);
    final endController = TextEditingController(text: entry.end);
    String selectedDay = entry.day;
    String selectedType = entry.type;
    String selectedMode = entry.mode;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: Text(
                'Reschedule Class',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: startController,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Start Time (HH:mm)',
                        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.access_time, color: Color(0xFF5B7CFF)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: endController,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'End Time (HH:mm)',
                        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.access_time, color: Color(0xFF5B7CFF)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Day',
                        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF5B7CFF)),
                      ),
                      items: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                          .map((day) => DropdownMenuItem(
                                value: day,
                                child: Text(day),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedDay = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Class Type',
                        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.class_, color: Color(0xFF5B7CFF)),
                      ),
                      items: ['Lecture', 'Tutorial', 'Sessional']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedMode,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Mode',
                        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.computer, color: Color(0xFF5B7CFF)),
                      ),
                      items: ['Online', 'Onsite']
                          .map((mode) => DropdownMenuItem(
                                value: mode,
                                child: Text(mode),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedMode = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newStart = startController.text.trim();
                    final newEnd = endController.text.trim();
                    
                    if (newStart.isNotEmpty && newEnd.isNotEmpty) {
                      await widget.repo.rescheduleClass(
                        entry,
                        newStart: newStart,
                        newEnd: newEnd,
                        newDay: selectedDay,
                        newType: selectedType,
                        newMode: selectedMode,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Class rescheduled successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B7CFF),
                  ),
                  child: Text('Save', style: GoogleFonts.poppins()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openProfile() {
    if (widget.admin.teacherInitial != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherProfileScreen(
            teacherInitial: widget.admin.teacherInitial!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacher = widget.repo.teacherByInitial(widget.admin.teacherInitial ?? '');
    final dayEntries = widget.repo.teacherEntriesForDay(
      widget.admin.teacherInitial ?? '',
      selectedDay,
    );

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
                      color: const Color(0xFFFF6B9D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.manage_accounts,
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
                          'Teacher Admin',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          teacher?.name ?? 'Teacher',
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
                    icon: const Icon(Icons.account_circle, color: Color(0xFF5B7CFF)),
                    onPressed: _openProfile,
                    tooltip: 'My Profile',
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),

            // Day Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: days.map((day) {
                    final isSelected = selectedDay == day;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDay = day),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF5B7CFF)
                              : const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: const Color(0xFF5B7CFF))
                              : null,
                        ),
                        child: Text(
                          day,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.grey[400],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Classes List
            Expanded(
              child: dayEntries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 80,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No classes scheduled for $selectedDay',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: dayEntries.length,
                      itemBuilder: (context, index) {
                        final entry = dayEntries[index];
                        final course = widget.repo.courseByCode(entry.courseCode);
                        final batch = widget.repo.batchById(entry.batchId);
                        final room = widget.repo.roomById(entry.roomId);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: entry.isCancelled
                                ? const Color(0xFF2A1E1E)
                                : const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: entry.isCancelled
                                  ? Colors.red.withOpacity(0.3)
                                  : const Color(0xFF5B7CFF).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: entry.isCancelled
                                          ? Colors.red.withOpacity(0.2)
                                          : const Color(0xFF5B7CFF).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${entry.start} - ${entry.end}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: entry.isCancelled
                                            ? Colors.red
                                            : const Color(0xFF5B7CFF),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (entry.isCancelled)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'CANCELLED',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                course?.title ?? entry.courseCode,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.group, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    batch?.name ?? entry.batchId,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.door_front_door,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    room?.name ?? 'TBA',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      entry.type,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (entry.isCancelled && entry.cancellationReason != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline,
                                          size: 14, color: Colors.red),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          entry.cancellationReason!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.red[300],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              if (!entry.isCancelled)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    SizedBox(
                                      width: (MediaQuery.of(context).size.width - 64) / 3,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _rescheduleClass(entry),
                                        icon: const Icon(Icons.schedule, size: 14),
                                        label: Text(
                                          'Reschedule',
                                          style: GoogleFonts.poppins(fontSize: 11),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF5B7CFF),
                                          side: const BorderSide(
                                              color: Color(0xFF5B7CFF)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (MediaQuery.of(context).size.width - 64) / 3,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _changeRoom(entry),
                                        icon: const Icon(Icons.edit_location, size: 14),
                                        label: Text(
                                          'Room',
                                          style: GoogleFonts.poppins(fontSize: 11),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF5B7CFF),
                                          side: const BorderSide(
                                              color: Color(0xFF5B7CFF)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (MediaQuery.of(context).size.width - 64) / 3,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _cancelClass(entry),
                                        icon: const Icon(Icons.cancel, size: 14),
                                        label: Text(
                                          'Cancel',
                                          style: GoogleFonts.poppins(fontSize: 11),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await widget.repo.uncancelClass(entry);
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.restore, size: 14),
                                    label: Text(
                                      'Restore Class',
                                      style: GoogleFonts.poppins(fontSize: 11),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green,
                                      side: const BorderSide(color: Colors.green),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
