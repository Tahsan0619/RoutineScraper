import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_repository.dart';
import '../widgets/gradient_shell.dart';
import '../widgets/schedule_list.dart';
import '../utils/date_utils.dart';

/// Student portal for viewing daily schedule
class StudentPortalScreen extends StatefulWidget {
  final DataRepository repo;

  const StudentPortalScreen({super.key, required this.repo});

  @override
  State<StudentPortalScreen> createState() => _StudentPortalScreenState();
}

class _StudentPortalScreenState extends State<StudentPortalScreen> {
  final idCtrl = TextEditingController();
  String? error;
  List entries = [];
  dynamic batch;

  void _lookup() {
    final sid = idCtrl.text.trim();
    setState(() {
      error = null;
      entries = [];
      batch = null;
    });

    final student = widget.repo.studentById(sid);
    if (student == null) {
      setState(() => error = 'Student ID not found');
      return;
    }

    final day = todayAbbrev();
    final fetchedEntries = widget.repo.batchEntriesForDay(student.batchId, day);
    
    setState(() {
      entries = fetchedEntries;
      batch = widget.repo.batchById(student.batchId);
      if (widget.repo.data!.meta.daysOff.contains(day)) {
        error = 'Today is off day ($day)';
      } else if (fetchedEntries.isEmpty) {
        error = 'No classes today for ${batch?.name ?? student.batchId}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.repo.data!.meta;
    final day = todayAbbrev();

    return GradientShell(
      title: 'Student Portal',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Student Portal",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text("Today: $day • Timezone: ${meta.tz}"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: idCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Enter Student ID',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _lookup(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _lookup,
                  icon: const Icon(Icons.search),
                  label: const Text('Find'),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: error!.contains('off day') || error!.contains('No classes')
                      ? Colors.orange.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      error!.contains('off day') || error!.contains('No classes')
                          ? Icons.weekend
                          : Icons.error_outline,
                      color: error!.contains('off day') || error!.contains('No classes')
                          ? Colors.orange.shade700
                          : Colors.red.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: error!.contains('off day') || error!.contains('No classes')
                              ? Colors.orange.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (entries.isNotEmpty) ...[
              const SizedBox(height: 20),
              ScheduleList(
                repo: widget.repo,
                title:
                    'Today\'s Schedule • ${batch?.name ?? ''} (${batch?.session ?? ''})',
                entries: entries.cast(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
