import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/data_repository.dart';
import '../services/supabase_service.dart';
import '../models/admin.dart';
import '../models/timetable_entry.dart';

/// Teacher admin portal for managing own classes
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

  @override
  Widget build(BuildContext context) {
    final teacher =
        widget.repo.teacherByInitial(widget.admin.teacherInitial!);
    final dayEntries = widget.repo
        .teacherEntriesForDay(widget.admin.teacherInitial!, selectedDay);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Teacher Admin Portal',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFF2A2A2A),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                        Icons.manage_accounts,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher?.name ?? 'Teacher',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Manage Your Classes',
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
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: days
                        .map((day) => ButtonSegment(
                              value: day,
                              label: Text(day),
                            ))
                        .toList(),
                    selected: {selectedDay},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        selectedDay = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Your Classes on $selectedDay',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: dayEntries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No classes scheduled for $selectedDay',
                            style: GoogleFonts.poppins(
                              color: Color(0xFFB0B0B0),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: dayEntries.length,
                      itemBuilder: (context, index) {
                        final entry = dayEntries[index];
                        final course =
                            widget.repo.courseByCode(entry.courseCode);
                        final batch = widget.repo.batchById(entry.batchId);
                        final room = widget.repo.roomById(entry.roomId);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: const Color(0xFF2A2A2A),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: entry.isCancelled
                                        ? const Color(0xFF5A3D3D)
                                        : const Color(0xFF3D4D5A),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        entry.start,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE0E0E0),
                                        ),
                                      ),
                                      Text(
                                        entry.end,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFFB0B0B0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${course?.title ?? entry.courseCode} • ${entry.type}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFE0E0E0),
                                          decoration: entry.isCancelled
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${batch?.name ?? entry.batchId} • ${entry.mode == 'Online' ? '🌐 Online' : '📍 ${room?.name ?? 'TBA'}'}${entry.isCancelled ? ' • Cancelled' : ''}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFB0B0B0),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: entry.isCancelled
                                      ? 'uncancel'
                                      : 'cancel',
                                  child: Row(
                                    children: [
                                      Icon(
                                        entry.isCancelled
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(entry.isCancelled
                                          ? 'Reactivate'
                                          : 'Cancel Class'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'toggle_mode',
                                  child: Row(
                                    children: [
                                      Icon(
                                        entry.mode == 'Online'
                                            ? Icons.meeting_room
                                            : Icons.language,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(entry.mode == 'Online'
                                          ? 'Switch to Offline'
                                          : 'Switch to Online'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'change_room',
                                  child: Row(
                                    children: [
                                      Icon(Icons.meeting_room, size: 20),
                                      SizedBox(width: 8),
                                      Text('Change Room'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'reschedule',
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_month, size: 20),
                                      SizedBox(width: 8),
                                      Text('Reschedule'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) async {
                                if (value == 'cancel') {
                                  _cancelClass(entry);
                                } else if (value == 'uncancel') {
                                  await widget.repo.uncancelClass(entry);
                                  setState(() {});
                                } else if (value == 'toggle_mode') {
                                  _toggleMode(entry);
                                } else if (value == 'change_room') {
                                  _changeRoom(entry);
                                } else if (value == 'reschedule') {
                                  _rescheduleClass(entry);
                                }
                              },
                            ),
                              ],
                            ),
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

  void _cancelClass(TimetableEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        final reasonCtrl = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Cancel Class',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter reason for cancellation:',
                  style: TextStyle(color: Color(0xFFE0E0E0)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    labelStyle: const TextStyle(color: Color(0xFF5B7CFF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF404040)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF5B7CFF)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await widget.repo.cancelClass(entry, reasonCtrl.text);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                setState(() {});
              },
              child: const Text('Confirm'),
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
        final rooms = widget.repo.data!.rooms;
        String? selectedRoomId = entry.roomId;

        return AlertDialog(
          title: const Text('Change Room'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select new room:'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRoomId,
                    decoration: const InputDecoration(
                      labelText: 'Room',
                      border: OutlineInputBorder(),
                    ),
                    items: rooms
                        .map((room) => DropdownMenuItem(
                              value: room.id,
                              child: Text(room.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRoomId = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (selectedRoomId != null) {
                  await widget.repo.changeRoom(entry, selectedRoomId!);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  setState(() {});
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _toggleMode(TimetableEntry entry) {
    final newMode = entry.mode == 'Online' ? 'Onsite' : 'Online';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Change Class Mode',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Change class from ${entry.mode} to $newMode?',
                  style: const TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
                ),
              const SizedBox(height: 16),
              if (newMode == 'Onsite')
                Column(
                  children: [
                    Text(
                      'Current room: ${entry.roomId}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The room assignment will remain the same.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF808080),
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'The class will be conducted online.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF808080),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await widget.repo.rescheduleClass(entry, newMode: newMode);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                setState(() {});
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _rescheduleClass(TimetableEntry entry) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    String? selectedDay = entry.day;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Reschedule Class',
            style: TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current day: ${entry.day}',
                    style: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select new day:',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    decoration: InputDecoration(
                      labelText: 'Day',
                      labelStyle: const TextStyle(color: Color(0xFF5B7CFF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF5B7CFF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF404040)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF5B7CFF)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                    ),
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF2A2A2A),
                    items: days
                        .map((day) => DropdownMenuItem(
                              value: day,
                              child: Text(day),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedDay = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (selectedDay != null && selectedDay != entry.day) {
                  await widget.repo.rescheduleClass(entry, newDay: selectedDay!);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  setState(() {});
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
