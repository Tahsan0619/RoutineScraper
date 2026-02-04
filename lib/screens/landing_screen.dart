import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/data_repository.dart';
import '../services/supabase_service.dart';
import '../widgets/gradient_shell.dart';
import '../widgets/brand_card.dart';
import '../widgets/big_nav_button.dart';
import 'student_portal_screen.dart';
import 'teacher_portal_screen.dart';
import 'admin_login_screen.dart';

/// Landing screen with role selection
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late final DataRepository repo;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    final service = context.read<SupabaseService>();
    service.initialize().then((_) {
      repo = DataRepository(service);
      return repo.load();
    }).then((_) {
      setState(() => loading = false);
    }).catchError((e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const GradientShell(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return GradientShell(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Failed to load data.json\n$error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return GradientShell(
      title: 'SmartRoutine',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BrandCard(meta: repo.data!.meta),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    BigNavButton(
                      icon: Icons.school,
                      label: "I'm a Student",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StudentPortalScreen(repo: repo),
                          ),
                        );
                      },
                    ),
                    BigNavButton(
                      icon: Icons.person,
                      label: "I'm a Teacher",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TeacherPortalScreen(repo: repo),
                          ),
                        );
                      },
                    ),
                    BigNavButton(
                      icon: Icons.admin_panel_settings,
                      label: "Login",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AdminLoginScreen(repo: repo),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
