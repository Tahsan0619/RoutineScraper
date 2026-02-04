import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_repository.dart';
import '../widgets/gradient_shell.dart';
import '../models/admin.dart';
import '../models/timetable_entry.dart';
import 'add_edit_schedule_screen.dart';

/// Super admin portal for full schedule management
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
  String selectedDay = 'Sun';
  final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final allEntries = widget.repo.getAllTimetableEntries();
    final dayEntries = allEntries
        .where((e) => e.day == selectedDay)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return GradientShell(
      title: 'Super Admin Portal',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Chairman',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Full Schedule Management Access',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => Navigator.of(context).pop(),
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
            Row(
              children: [
                Text(
                  'Schedule for $selectedDay',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditScheduleScreen(
                          repo: widget.repo,
                          day: selectedDay,
                        ),
                      ),
                    );
                    if (result == true) {
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Class'),
                ),
              ],
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
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No classes scheduled for $selectedDay',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: dayEntries.length,
                      itemBuilder: (context, index) {
                        final entry = dayEntries[index];
                        final teacher = widget.repo
                            .teacherByInitial(entry.teacherInitial);
                        final course =
                            widget.repo.courseByCode(entry.courseCode);
                        final batch = widget.repo.batchById(entry.batchId);
                        final room = widget.repo.roomById(entry.roomId);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: entry.isCancelled
                                    ? Colors.red.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    entry.start,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: entry.isCancelled
                                          ? Colors.red.shade700
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                  Text(
                                    entry.end,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: entry.isCancelled
                                          ? Colors.red.shade700
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              '${course?.title ?? entry.courseCode} • ${entry.type}',
                              style: TextStyle(
                                decoration: entry.isCancelled
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${teacher?.name ?? entry.teacherInitial} • ${batch?.name ?? entry.batchId}',
                                ),
                                Text(
                                  entry.mode == 'Online'
                                      ? 'Online'
                                      : room?.name ?? 'No room',
                                ),
                                if (entry.isCancelled)
                                  Text(
                                    'Cancelled: ${entry.cancellationReason ?? 'No reason'}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
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
                                          : 'Cancel'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20,
                                          color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete',
                                          style: TextStyle(color: Colors.red)),
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
                                } else if (value == 'delete') {
                                  _deleteClass(entry);
                                } else if (value == 'edit') {
                                  final result =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AddEditScheduleScreen(
                                        repo: widget.repo,
                                        day: selectedDay,
                                        editEntry: entry,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {});
                                  }
                                }
                              },
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
          title: const Text('Cancel Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter reason for cancellation:'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
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

  void _deleteClass(TimetableEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text(
          'Are you sure you want to delete this class? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await widget.repo.removeTimetableEntry(entry);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              setState(() {});
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
