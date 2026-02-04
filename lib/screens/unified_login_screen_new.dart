import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../services/data_repository.dart';
import '../models/admin.dart';
import 'main_navigation_screen.dart';
import 'super_admin_portal_screen_new.dart';
import 'teacher_admin_portal_screen_new.dart';
import '../models/teacher.dart';

/// Unified login screen for students, admins, and super admins
class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginAsAdmin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both username and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final service = context.read<SupabaseService>();
    
    // Try admin authentication first
    final admin = await service.authenticateAdmin(username, password);

    if (!mounted) return;

    if (admin != null) {
      setState(() => _isLoading = false);
      
      // Admin login successful
      if (admin.isSuperAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: service,
              child: const SuperAdminPortalScreenNew(),
            ),
          ),
        );
      } else {
        // Teacher Admin Portal
        final repo = DataRepository(service);
        await repo.load();
        
        if (!mounted) return;
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: service,
              child: TeacherAdminPortalScreen(
                repo: repo,
                admin: admin,
              ),
            ),
          ),
        );
      }
      return;
    }

    // Try teacher authentication
    final teacher = await service.authenticateTeacherByEmail(username, password);

    if (!mounted) return;

    if (teacher != null) {
      setState(() => _isLoading = false);
      
      // Teacher login successful - convert to Admin object for portal compatibility
      final Admin teacherAdmin = Admin(
        id: teacher.id,
        username: teacher.name,
        password: teacher.password ?? '',
        type: 'teacher_admin',
        teacherInitial: teacher.initial,
      );
      
      final repo = DataRepository(service);
      await repo.load();
      
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: service,
            child: TeacherAdminPortalScreen(repo: repo, admin: teacherAdmin),
          ),
        ),
      );
      return;
    }

    // Try student authentication
    final student = await service.authenticateStudent(username, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (student != null) {
      // Student login successful
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: service,
            child: const MainNavigationScreen(),
          ),
        ),
      );
      return;
    }

    // Both authentications failed
    setState(() {
      _errorMessage = 'Invalid credentials';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo and Title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B7CFF), Color(0xFF8A5BFF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.school_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'EDTE Routine',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'University Schedule Management',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                // Admin Login Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF5B7CFF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B7CFF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Color(0xFF5B7CFF),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Username Field
                      TextField(
                        controller: _usernameController,
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.person, color: Color(0xFF5B7CFF)),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      
                      const SizedBox(height: 16),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFF5B7CFF)),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.red[300],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _loginAsAdmin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B7CFF),
                            disabledBackgroundColor: const Color(0xFF5B7CFF).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[300],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
