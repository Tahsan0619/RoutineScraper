import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_repository.dart';
import '../services/supabase_service.dart';
import 'student_screen.dart';
import 'teacher_screen.dart';
import 'room_screen.dart';
import 'free_rooms_screen.dart';
import 'student_profile_screen.dart';

/// Main navigation screen with bottom navigation bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final DataRepository _repo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final service = context.read<SupabaseService>();
      await service.initialize();
      final repo = DataRepository(service);
      await repo.load();
      setState(() {
        _repo = repo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Widget> _getScreens() {
    if (_isLoading || _error != null) {
      return [
        Center(child: _isLoading ? const CircularProgressIndicator() : Text(_error!)),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
      ];
    }
    return [
      StudentScreen(repo: _repo),
      TeacherScreen(repo: _repo),
      RoomScreen(repo: _repo),
      FreeRoomsScreen(repo: _repo),
      const StudentProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _getScreens();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Student',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Teacher',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Room',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.door_front_door),
            label: 'Empty',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
