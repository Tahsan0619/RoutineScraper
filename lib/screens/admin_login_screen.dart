import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_repository.dart';
import '../widgets/gradient_shell.dart';
import '../models/admin.dart';
import 'super_admin_portal_screen.dart';
import 'teacher_admin_portal_screen.dart';

/// Admin login screen
class AdminLoginScreen extends StatefulWidget {
  final DataRepository repo;

  const AdminLoginScreen({super.key, required this.repo});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String? error;
  bool isLoading = false;

  void _login() async {
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => error = 'Please enter both username and password');
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final admin = widget.repo.authenticateAdmin(username, password);

    if (!mounted) return;

    if (admin == null) {
      setState(() {
        error = 'Invalid username or password';
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = false);

    // Navigate based on admin type
    if (admin.isSuperAdmin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SuperAdminPortalScreen(
            repo: widget.repo,
            admin: admin,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TeacherAdminPortalScreen(
            repo: widget.repo,
            admin: admin,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientShell(
      title: 'Login',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Admin Portal',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login to manage schedules',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      enabled: !isLoading,
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      enabled: !isLoading,
                      onSubmitted: (_) => _login(),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                error!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : _login,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(isLoading ? 'Logging in...' : 'Login'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo Credentials:',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Super Admin: chairman / chairman123',
                            style: GoogleFonts.poppins(fontSize: 11),
                          ),
                          Text(
                            'Teacher Admin: AZ / az123',
                            style: GoogleFonts.poppins(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
