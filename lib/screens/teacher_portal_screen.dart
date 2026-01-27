import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/data_repository.dart';
import '../widgets/gradient_shell.dart';
import '../widgets/teacher_card.dart';
import '../widgets/schedule_list.dart';
import '../utils/date_utils.dart';
import '../models/timetable_entry.dart';

/// Teacher portal for viewing schedules and exporting PDF
class TeacherPortalScreen extends StatefulWidget {
  final DataRepository repo;

  const TeacherPortalScreen({super.key, required this.repo});

  @override
  State<TeacherPortalScreen> createState() => _TeacherPortalScreenState();
}

class _TeacherPortalScreenState extends State<TeacherPortalScreen> {
  final initCtrl = TextEditingController();
  String? error;
  List todayEntries = [];
  dynamic selected;
  String viewMode = 'daily'; // 'daily' or 'weekly'
  Map<String, List<TimetableEntry>> weeklyData = {};

  void _search() {
    final init = initCtrl.text.trim().toUpperCase();
    final allowed = widget.repo.allowedTeacherInitials();
    
    setState(() {
      error = null;
      todayEntries = [];
      selected = null;
      weeklyData = {};
    });

    if (!allowed.contains(init)) {
      setState(() =>
          error = 'Invalid initials. Allowed: ${allowed.join(', ')}');
      return;
    }

    final t = widget.repo.teacherByInitial(init);
    final day = todayAbbrev();
    final entries = widget.repo.teacherEntriesForDay(init, day);
    final weekly = widget.repo.teacherWeeklyEntries(init);

    setState(() {
      selected = t;
      todayEntries = entries;
      weeklyData = weekly;
      if (widget.repo.data!.meta.daysOff.contains(day) && entries.isEmpty) {
        error = 'Today is off day ($day)';
      } else if (entries.isEmpty) {
        error = 'No classes today for ${t?.name ?? init}';
      }
    });
  }

  Future<void> _exportPDF() async {
    if (selected == null) return;

    final pdf = pw.Document();
    final teacher = selected;

    // Create PDF content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  widget.repo.data!.meta.department,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  widget.repo.data!.meta.university,
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 12),
                pw.Divider(),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Teacher: ${teacher.name} (${teacher.initial})',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('Designation: ${teacher.designation}'),
          pw.Text('Department: ${teacher.homeDepartment}'),
          pw.SizedBox(height: 16),
          pw.Text(
            'Weekly Schedule',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ...weeklyData.entries.map((dayEntry) {
            final day = dayEntry.key;
            final entries = dayEntry.value;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  color: PdfColors.blue100,
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    day,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                if (entries.isEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('No classes',
                        style: const pw.TextStyle(color: PdfColors.grey)),
                  )
                else
                  ...entries.map((e) {
                    final course =
                        widget.repo.courseByCode(e.courseCode)?.title ??
                            e.courseCode;
                    final room = e.mode == 'Online'
                        ? 'Online'
                        : (widget.repo.roomById(e.roomId)?.name ?? '');
                    final batch =
                        widget.repo.batchById(e.batchId)?.name ?? e.batchId;

                    return pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      margin: const pw.EdgeInsets.only(bottom: 4),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '$course • ${e.type}${e.group != null ? ' (${e.group})' : ''}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            'Time: ${e.start} - ${e.end} • $batch • $room',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  }),
                pw.SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.repo.data!.meta;
    final day = todayAbbrev();

    return GradientShell(
      title: 'Teacher Portal',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Teacher Portal",
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
                    controller: initCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Enter Initials (e.g., AZ, RS)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _search,
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
            if (selected != null) ...[
              const SizedBox(height: 16),
              TeacherCard(teacher: selected),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'daily',
                          label: Text('Daily'),
                          icon: Icon(Icons.today),
                        ),
                        ButtonSegment(
                          value: 'weekly',
                          label: Text('Weekly'),
                          icon: Icon(Icons.calendar_view_week),
                        ),
                      ],
                      selected: {viewMode},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          viewMode = newSelection.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _exportPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (viewMode == 'daily') ...[
                Text(
                  "Today's Classes",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (todayEntries.isNotEmpty)
                  ScheduleList(
                    repo: widget.repo,
                    title: null,
                    entries: todayEntries.cast(),
                  ),
              ] else ...[
                Text(
                  "Weekly Schedule",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...weeklyData.entries.map((dayEntry) {
                  final dayName = dayEntry.key;
                  final entries = dayEntry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dayName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (entries.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('No classes scheduled'),
                        )
                      else
                        ScheduleList(
                          repo: widget.repo,
                          title: null,
                          entries: entries,
                        ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
