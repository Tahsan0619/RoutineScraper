import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_repository.dart';
import '../models/room.dart';

/// Screen to manage all rooms
class ManageRoomsScreen extends StatefulWidget {
  final DataRepository repo;

  const ManageRoomsScreen({
    super.key,
    required this.repo,
  });

  @override
  State<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends State<ManageRoomsScreen> {
  late List<Room> rooms;
  late List<Room> filteredRooms;
  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    rooms = widget.repo.data?.rooms ?? [];
    filteredRooms = rooms;
    searchCtrl.addListener(_filterRooms);
  }

  void _filterRooms() {
    final query = searchCtrl.text.toLowerCase();
    setState(() {
      filteredRooms = rooms
          .where((r) =>
              r.name.toLowerCase().contains(query) ||
              r.id.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Manage Rooms',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search rooms...',
                hintStyle: const TextStyle(color: Color(0xFF808080)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF5B7CFF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF5B7CFF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF404040)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF5B7CFF)),
                ),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
              ),
            ),
          ),
          Expanded(
            child: filteredRooms.isEmpty
                ? Center(
                    child: Text(
                      'No rooms found',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      final scheduleCount = widget.repo
                          .getAllTimetableEntries()
                          .where((e) => e.roomId == room.id)
                          .length;
                      return _buildRoomCard(room, scheduleCount);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room, int scheduleCount) {
    final isLab = room.name.toLowerCase().contains('lab');
    final gradient = isLab
        ? const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFFB74D)])
        : const LinearGradient(colors: [Color(0xFF5B7CFF), Color(0xFF8A5BFF)]);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLab
              ? const Color(0xFFFF6B9D).withOpacity(0.3)
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    isLab ? Icons.computer : Icons.meeting_room,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'ID: ${room.id}',
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isLab
                  ? const Color(0xFFFF6B9D).withOpacity(0.2)
                  : const Color(0xFF5B7CFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color:
                      isLab ? const Color(0xFFFF6B9D) : const Color(0xFF5B7CFF),
                ),
                const SizedBox(width: 8),
                Text(
                  '$scheduleCount classes scheduled',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isLab
                        ? const Color(0xFFFF6B9D)
                        : const Color(0xFF5B7CFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
