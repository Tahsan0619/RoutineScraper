import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/data_repository.dart';
import '../services/supabase_service.dart';
import 'main_navigation_screen.dart';
import 'teacher_admin_portal_screen.dart';
import 'super_admin_portal_screen.dart';

/// Unified login screen for students, admins, and super admins
/// 
/// Default Credentials:
/// - Student: Any student ID from data (guest mode - no login required)
/// - Teacher Admin: username: teacher@edte  password: teacher123
/// - Super Admin: username: admin@edte  password: admin123
class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentEmailController = TextEditingController();
  final _studentPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isStudentLoading = false;
  String? _errorMessage;
  String? _studentErrorMessage;
  late DataRepository _repo;
  bool _dataLoaded = false;

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
        _dataLoaded = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _dataLoaded = false;
      });
    }
  }

  Future<void> _loginAsStudent() async {
    if (!_dataLoaded) return;

    final email = _studentEmailController.text.trim();
    final password = _studentPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _studentErrorMessage = 'Please enter both email and password');
      return;
    }

    setState(() {
      _isStudentLoading = true;
      _studentErrorMessage = null;
    });

    final service = context.read<SupabaseService>();
    final student = await service.authenticateStudent(email, password);

    if (!mounted) return;

    if (student == null) {
      setState(() {
        _studentErrorMessage = 'Invalid email or password';
        _isStudentLoading = false;
      });
      return;
    }

    setState(() => _isStudentLoading = false);

    // Navigate to main navigation screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );
    }
  }

  Future<void> _loginAsAdmin() async {
    if (!_dataLoaded) return;

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

    await Future.delayed(const Duration(milliseconds: 500));

    final service = context.read<SupabaseService>();
    final admin = await service.authenticateAdmin(username, password);

    if (!mounted) return;

    if (admin == null) {
      setState(() {
        _errorMessage = 'Invalid credentials';
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = false);

    if (admin.isSuperAdmin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SuperAdminPortalScreen(
            repo: _repo,
            admin: admin,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TeacherAdminPortalScreen(
            repo: _repo,
            admin: admin,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: !_dataLoaded
            ? Center(
                child: _errorMessage != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 64, color: Colors.red[400]),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.poppins(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              )
            : SingleChildScrollView(
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
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'Routine Scrapper',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'University Schedule Management',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Student Login Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF8A5BFF).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8A5BFF).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    color: Color(0xFF8A5BFF),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Student Login',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Email Field
                            TextField(
                              controller: _studentEmailController,
                              style: GoogleFonts.poppins(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFF2A2A2A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Password Field
                            TextField(
                              controller: _studentPasswordController,
                              obscureText: true,
                              style: GoogleFonts.poppins(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFF2A2A2A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (_) => _loginAsStudent(),
                            ),
                            
                            if (_studentErrorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _studentErrorMessage!,
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
                            ElevatedButton(
                              onPressed: _isStudentLoading ? null : _loginAsStudent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8A5BFF),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isStudentLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Login as Student',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Admin Login Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF5B7CFF).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFF2A2A2A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Password Field
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: GoogleFonts.poppins(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFF2A2A2A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (_) => _loginAsAdmin(),
                            ),
                            
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
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
                            ElevatedButton(
                              onPressed: _isLoading ? null : _loginAsAdmin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B7CFF),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
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
                            
                            const SizedBox(height: 16),
                            
                            // Default Credentials Info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Default Credentials:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildCredentialRow('Teacher Admin', 'teacher@edte / teacher123'),
                                  const SizedBox(height: 4),
                                  _buildCredentialRow('Super Admin', 'admin@edte / admin123'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      Text(
                        'Version 5.1 • January 2026',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAccessCard({
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B7CFF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String role, String credentials) {
    return Row(
      children: [
        Icon(Icons.vpn_key, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$role: ',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        Text(
          credentials,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF5B7CFF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
