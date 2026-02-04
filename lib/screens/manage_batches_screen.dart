import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_repository.dart';
import '../models/batch.dart';

/// Screen to manage all batches
class ManageBatchesScreen extends StatefulWidget {
  final DataRepository repo;

  const ManageBatchesScreen({
    super.key,
    required this.repo,
  });

  @override
  State<ManageBatchesScreen> createState() => _ManageBatchesScreenState();
}

class _ManageBatchesScreenState extends State<ManageBatchesScreen> {
  late List<Batch> batches;
  late List<Batch> filteredBatches;
  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    batches = widget.repo.data?.batches ?? [];
    filteredBatches = batches;
    searchCtrl.addListener(_filterBatches);
  }

  void _filterBatches() {
    final query = searchCtrl.text.toLowerCase();
    setState(() {
      filteredBatches = batches
          .where((b) =>
              b.name.toLowerCase().contains(query) ||
              b.session.toLowerCase().contains(query))
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
          'Manage Batches',
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
                hintText: 'Search batches...',
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
            child: filteredBatches.isEmpty
                ? Center(
                    child: Text(
                      'No batches found',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredBatches.length,
                    itemBuilder: (context, index) {
                      final batch = filteredBatches[index];
                      final classCount = widget.repo
                          .getAllTimetableEntries()
                          .where((e) => e.batchId == batch.id)
                          .length;
                      return _buildBatchCard(batch, classCount);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(Batch batch, int classCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8A5BFF).withOpacity(0.3),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A5BFF), Color(0xFFFF6B9D)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    batch.name.split('-').last,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      batch.session,
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
              color: const Color(0xFF8A5BFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.class_, size: 16, color: Color(0xFF8A5BFF)),
                const SizedBox(width: 8),
                Text(
                  '$classCount classes scheduled',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF8A5BFF),
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
