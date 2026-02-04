import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/data_repository.dart';
import '../services/supabase_service.dart';
import '../widgets/department_dropdown.dart';
import '../widgets/online_badge.dart';
import '../utils/date_utils.dart';

/// Free Rooms screen for viewing available rooms by time slot
class FreeRoomsScreen extends StatefulWidget {
  final DataRepository repo;

  const FreeRoomsScreen({super.key, required this.repo});

  @override
  State<FreeRoomsScreen> createState() => _FreeRoomsScreenState();
}

class _FreeRoomsScreenState extends State<FreeRoomsScreen> {
  String _selectedDepartment = 'EdTE';
  String? _selectedTimeSlot;

  final Map<String, List<String>> _timeSlots = {
    'MORNING': [
      '08:30-10:00',
      '10:00-11:30',
      '11:30-01:00',
    ],
    'AFTERNOON': [
      '01:00-02:30',
      '02:30-04:00',
    ],
  };

  List<String> _getFreeRooms() {
    if (_selectedTimeSlot == null) return [];
    
    final day = todayAbbrev();
    final allRooms = widget.repo.data!.rooms;
    final freeRooms = <String>[];

    for (var room in allRooms) {
      final entries = widget.repo.roomEntriesForDayTime(
        room.id,
        day,
        _selectedTimeSlot!,
      );
      
      if (entries.isEmpty) {
        freeRooms.add(room.name);
      }
    }

    return freeRooms;
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
    final freeRooms = _getFreeRooms();

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
                      color: const Color(0xFF8A5BFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.event_available, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Free Rooms',
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
            
            // Department and Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Text(
                            'Select Time Slot',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DepartmentDropdown(
                    value: _selectedDepartment,
                    onChanged: (value) => setState(() => _selectedDepartment = value!),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Time Slots
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ..._timeSlots.entries.map((category) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: category.key == 'MORNING' 
                                    ? const Color(0xFFFF9800)
                                    : const Color(0xFF5B7CFF),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.key,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Time Slots
                        ...category.value.map((timeSlot) {
                          final isSelected = _selectedTimeSlot == timeSlot;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedTimeSlot = timeSlot),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFF5B7CFF).withOpacity(0.2)
                                    : const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected 
                                      ? const Color(0xFF5B7CFF)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: isSelected ? const Color(0xFF5B7CFF) : Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    timeSlot,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isSelected && freeRooms.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF5B7CFF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${freeRooms.length} free',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                  
                  // Free Rooms Display
                  if (_selectedTimeSlot != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Free Rooms',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (freeRooms.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.event_busy, size: 60, color: Colors.grey[700]),
                              const SizedBox(height: 12),
                              Text(
                                'No free rooms at this time',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: freeRooms.map((room) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF5B7CFF), width: 1),
                            ),
                            child: Text(
                              'Room $room',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
