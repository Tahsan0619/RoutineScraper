import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_repository.dart';
import '../widgets/gradient_shell.dart';
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

  @override
  Widget build(BuildContext context) {
    final teacher =
        widget.repo.teacherByInitial(widget.admin.teacherInitial!);
    final dayEntries = widget.repo
        .teacherEntriesForDay(widget.admin.teacherInitial!, selectedDay);

    return GradientShell(
      title: 'Teacher Admin Portal',
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
                    const Icon(Icons.manage_accounts, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher?.name ?? 'Teacher',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage Your Classes',
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
            Text(
              'Your Classes on $selectedDay',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
                                Text('${batch?.name ?? entry.batchId}'),
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
                              ],
                              onSelected: (value) {
                                if (value == 'cancel') {
                                  _cancelClass(entry);
                                } else if (value == 'uncancel') {
                                  widget.repo.uncancelClass(entry);
                                  setState(() {});
                                } else if (value == 'change_room') {
                                  _changeRoom(entry);
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
              onPressed: () {
                widget.repo.cancelClass(entry, reasonCtrl.text);
                Navigator.of(context).pop();
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
              onPressed: () {
                if (selectedRoomId != null) {
                  widget.repo.changeRoom(entry, selectedRoomId!);
                  Navigator.of(context).pop();
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
