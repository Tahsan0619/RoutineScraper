import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_repository.dart';
import '../widgets/gradient_shell.dart';
import '../models/timetable_entry.dart';

/// Screen for adding or editing schedule entries
class AddEditScheduleScreen extends StatefulWidget {
  final DataRepository repo;
  final String day;
  final TimetableEntry? editEntry;

  const AddEditScheduleScreen({
    super.key,
    required this.repo,
    required this.day,
    this.editEntry,
  });

  @override
  State<AddEditScheduleScreen> createState() => _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState extends State<AddEditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedBatchId;
  String? selectedTeacherInitial;
  String? selectedCourseCode;
  String? selectedType;
  String? selectedGroup;
  String? selectedRoomId;
  String? selectedMode;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final types = ['Lecture', 'Tutorial', 'Sessional', 'Online'];
  final modes = ['Onsite', 'Online'];
  final groups = ['None', 'G-1', 'G-2'];

  @override
  void initState() {
    super.initState();
    if (widget.editEntry != null) {
      _loadEditData();
    }
  }

  void _loadEditData() {
    final entry = widget.editEntry!;
    selectedBatchId = entry.batchId;
    selectedTeacherInitial = entry.teacherInitial;
    selectedCourseCode = entry.courseCode;
    selectedType = entry.type;
    selectedGroup = entry.group ?? 'None';
    selectedRoomId = entry.roomId;
    selectedMode = entry.mode;
    
    // Parse time
    final startParts = entry.start.split(':');
    startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );
    final endParts = entry.end.split(':');
    endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final batches = widget.repo.data!.batches;
    final teachers = widget.repo.data!.teachers;
    final courses = widget.repo.data!.courses;
    final rooms = widget.repo.data!.rooms;

    return GradientShell(
      title: widget.editEntry == null ? 'Add Class' : 'Edit Class',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day: ${widget.day}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: selectedBatchId,
                decoration: const InputDecoration(
                  labelText: 'Batch *',
                  border: OutlineInputBorder(),
                ),
                items: batches
                    .map((batch) => DropdownMenuItem(
                          value: batch.id,
                          child: Text('${batch.name} (${batch.session})'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBatchId = value;
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTeacherInitial,
                decoration: const InputDecoration(
                  labelText: 'Teacher *',
                  border: OutlineInputBorder(),
                ),
                items: teachers
                    .map((teacher) => DropdownMenuItem(
                          value: teacher.initial,
                          child: Text('${teacher.name} (${teacher.initial})'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTeacherInitial = value;
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCourseCode,
                decoration: const InputDecoration(
                  labelText: 'Course *',
                  border: OutlineInputBorder(),
                ),
                items: courses
                    .map((course) => DropdownMenuItem(
                          value: course.code,
                          child: Text('${course.code} - ${course.title}'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCourseCode = value;
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type *',
                        border: OutlineInputBorder(),
                      ),
                      items: types
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value;
                        });
                      },
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedGroup,
                      decoration: const InputDecoration(
                        labelText: 'Group',
                        border: OutlineInputBorder(),
                      ),
                      items: groups
                          .map((group) => DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGroup = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMode,
                decoration: const InputDecoration(
                  labelText: 'Mode *',
                  border: OutlineInputBorder(),
                ),
                items: modes
                    .map((mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(mode),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMode = value;
                    if (value == 'Online') {
                      selectedRoomId = null;
                    }
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              if (selectedMode == 'Onsite')
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
                    setState(() {
                      selectedRoomId = value;
                    });
                  },
                ),
              const SizedBox(height: 16),
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
                          setState(() {
                            startTime = time;
                          });
                        }
                      },
                      icon: const Icon(Icons.access_time),
                      label: Text(startTime == null
                          ? 'Start Time *'
                          : '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: endTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            endTime = time;
                          });
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
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saveEntry,
                      child: Text(widget.editEntry == null ? 'Add' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEntry() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end time')),
      );
      return;
    }

    final entry = TimetableEntry(
      day: widget.day,
      batchId: selectedBatchId!,
      teacherInitial: selectedTeacherInitial!,
      courseCode: selectedCourseCode!,
      type: selectedType!,
      group: selectedGroup == 'None' ? null : selectedGroup,
      roomId: selectedMode == 'Online' ? null : selectedRoomId,
      mode: selectedMode!,
      start:
          '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
      end:
          '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}',
    );

    widget.repo.addTimetableEntry(entry);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.editEntry == null
            ? 'Class added successfully'
            : 'Class updated successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(true);
  }
}
