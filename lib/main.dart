import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'services/data_repository.dart';
import 'models/admin.dart';
import 'screens/unified_login_screen_new.dart';
import 'screens/super_admin_portal_screen_new.dart';
import 'screens/teacher_admin_portal_screen_new.dart';
import 'screens/main_navigation_screen.dart';

/// Routine Scrapper - University Schedule Management System
/// A class schedule management app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://yofrdlyzetcezbhhbkdb.supabase.co',
    anonKey: 'sb_publishable_YEooiBZGo8WjkgFu5mfqlw_mC-6d0YM',
  );
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const RoutineScrapperApp());
}

/// Main application widget
class RoutineScrapperApp extends StatelessWidget {
  const RoutineScrapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dark theme color scheme
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFF5B7CFF),
      secondary: const Color(0xFF8A5BFF),
      surface: const Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    );

    return ChangeNotifierProvider(
      create: (_) {
        final service = SupabaseService();
        // Initialize service asynchronously
        service.initialize();
        return service;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EDTE Routine Scrapper',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: const Color(0xFF121212),
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF1E1E1E),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5B7CFF), width: 2),
            ),
            hintStyle: TextStyle(color: Colors.grey[600]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF2A2A2A),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B7CFF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: const Color(0xFF1E1E1E),
            selectedItemColor: const Color(0xFF5B7CFF),
            unselectedItemColor: Colors.grey[600],
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
        home: const AuthCheck(),
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(builder: (_) => const AuthCheck());
          }
          return null;
        },
      ),
    );
  }
}

/// Widget to check authentication state
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  late DataRepository _repo;
  bool _repoInitialized = false;
  bool _serviceInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRepo();
  }

  Future<void> _initializeRepo() async {
    final service = context.read<SupabaseService>();
    await service.initialize();
    _repo = DataRepository(service);
    await _repo.load();
    if (mounted) {
      setState(() {
        _repoInitialized = true;
        _serviceInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_repoInitialized || !_serviceInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF5B7CFF),
          ),
        ),
      );
    }

    return Consumer<SupabaseService>(
      builder: (context, supabaseService, _) {
        // If user is already logged in, show the appropriate dashboard
        if (supabaseService.currentAdmin != null) {
          final admin = supabaseService.currentAdmin!;
          if (admin.type == 'super_admin') {
            return const SuperAdminPortalScreenNew();
          } else if (admin.type == 'teacher_admin') {
            return TeacherAdminPortalScreen(
              repo: _repo,
              admin: admin,
            );
          }
        }
        
        // Check if student is logged in
        if (supabaseService.currentStudent != null) {
          return const MainNavigationScreen();
        }
        
        // Check if teacher is logged in
        if (supabaseService.currentTeacher != null) {
          return TeacherAdminPortalScreen(
            repo: _repo,
            admin: Admin(
              id: supabaseService.currentTeacher!.id,
              username: supabaseService.currentTeacher!.name,
              password: supabaseService.currentTeacher!.password ?? '',
              type: 'teacher_admin',
              teacherInitial: supabaseService.currentTeacher!.initial,
            ),
          );
        }
        
        // Otherwise show login screen
        return const UnifiedLoginScreen();
      },
    );
  }
}
