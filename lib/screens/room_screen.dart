import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/data_repository.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/department_dropdown.dart';
import '../widgets/online_badge.dart';
import '../widgets/schedule_card.dart';

/// Room screen for searching schedules by room, day, and time
class RoomScreen extends StatefulWidget {
  final DataRepository repo;

  const RoomScreen({super.key, required this.repo});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _roomController = TextEditingController();
  String _selectedDepartment = 'EdTE';
  String? _selectedDay;
  String? _selectedTime;
  List _scheduleEntries = [];
  bool _hasSearched = false;

  final List<String> _days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final List<String> _times = [
    '08:30-10:00',
    '10:00-11:30',
    '11:30-01:00',
    '01:00-02:30',
    '02:30-04:00',
  ];

  void _searchSchedule() {
    final roomNumber = _roomController.text.trim();
    if (roomNumber.isEmpty || _selectedDay == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Find room
    dynamic room;
    for (var r in widget.repo.data!.rooms) {
      if (r.name.toLowerCase() == roomNumber.toLowerCase() || 
          r.id.toLowerCase() == roomNumber.toLowerCase()) {
        room = r;
        break;
      }
    }

    if (room == null) {
      setState(() {
        _hasSearched = true;
        _scheduleEntries = [];
      });
      return;
    }

    // Get entries for that room, day, and time
    final entries = widget.repo.roomEntriesForDayTime(
      room.id,
      _selectedDay!,
      _selectedTime!,
    );

    setState(() {
      _scheduleEntries = entries;
      _hasSearched = true;
    });
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await context.read<SupabaseService>().logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B7CFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.door_front_door, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Room',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const OnlineBadge(),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => _showSettingsMenu(context),
                  ),
                ],
              ),
            ),
            
            // Search Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    
                    // Room Number Input
                    CustomInputField(
                      controller: _roomController,
                      hintText: 'Room Number (e.g., 611)',
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Day and Time Dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdown<String>(
                            value: _selectedDay,
                            hint: 'Select Day',
                            items: _days,
                            onChanged: (value) => setState(() => _selectedDay = value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomDropdown<String>(
                            value: _selectedTime,
                            hint: 'Select Time',
                            items: _times,
                            onChanged: (value) => setState(() => _selectedTime = value),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Department Dropdown
                    DepartmentDropdown(
                      value: _selectedDepartment,
                      onChanged: (value) => setState(() => _selectedDepartment = value!),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _searchSchedule,
                        icon: const Icon(Icons.search),
                        label: Text(
                          'Get Schedule',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF5B7CFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Results
                    if (_hasSearched)
                      _scheduleEntries.isEmpty
                          ? Column(
                              children: [
                                Icon(Icons.event_available, size: 80, color: Colors.grey[700]),
                                const SizedBox(height: 16),
                                Text(
                                  'Room is free at this time',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: _scheduleEntries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ScheduleCard(entry: entry, repo: widget.repo),
                                );
                              }).toList(),
                            ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }
}
