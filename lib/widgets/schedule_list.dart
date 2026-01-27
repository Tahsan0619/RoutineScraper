import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/timetable_entry.dart';
import '../services/data_repository.dart';

/// Schedule list widget for displaying timetable entries
class ScheduleList extends StatelessWidget {
  final DataRepository repo;
  final String? title;
  final List<TimetableEntry> entries;

  const ScheduleList({
    super.key,
    required this.repo,
    required this.entries,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
            ],
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = entries[i];
                final course =
                    repo.courseByCode(e.courseCode)?.title ?? e.courseCode;
                final room = e.mode == 'Online'
                    ? 'Online'
                    : (repo.roomById(e.roomId)?.name ?? '');
                final batchName = repo.batchById(e.batchId)?.name ?? e.batchId;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: e.isCancelled
                        ? Colors.red.shade300
                        : const Color(0xFF1976D2),
                    child: Text(
                      e.start,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    '$course • ${e.type}${e.group != null ? ' (${e.group})' : ''}',
                    style: TextStyle(
                      decoration:
                          e.isCancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${e.mode == 'Online' ? 'Online' : room} • $batchName • ${e.start}-${e.end}',
                      ),
                      if (e.isCancelled)
                        Text(
                          'CANCELLED: ${e.cancellationReason ?? 'No reason provided'}',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: e.isCancelled
                      ? Icon(Icons.cancel, color: Colors.red.shade700)
                      : (e.mode == 'Online'
                          ? const Icon(Icons.wifi, color: Colors.green)
                          : const Icon(Icons.meeting_room)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
