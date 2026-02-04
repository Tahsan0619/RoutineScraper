import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_repository.dart';

/// Schedule card widget to display class information
class ScheduleCard extends StatelessWidget {
  final dynamic entry;
  final DataRepository repo;

  const ScheduleCard({
    super.key,
    required this.entry,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    final course = repo.courseByCode(entry.courseCode);
    final teacher = repo.teacherByInitial(entry.teacherInitial);
    final room = repo.roomById(entry.roomId);
    final batch = repo.batchById(entry.batchId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5B7CFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course and Time
          Row(
            children: [
              Expanded(
                child: Text(
                  course?.title ?? entry.courseCode,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B7CFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.start}-${entry.end}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5B7CFF),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Details
          _buildDetailRow(Icons.person, teacher?.name ?? entry.teacherInitial),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.door_front_door, 'Room ${room?.name ?? entry.roomId ?? 'N/A'}'),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.group, batch?.name ?? entry.batchId),
          if (entry.type != null && entry.type.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow(Icons.book, entry.type),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }
}
