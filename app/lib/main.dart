import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/habit_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await AuthService().initialize();
  await HabitService().initializeDefaultHabits();
  
  runApp(const DeenTrackerApp());
}

class DeenTrackerApp extends StatelessWidget {
  const DeenTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: MaterialApp(
        title: 'Deen Tracker',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool get isLoggedIn => _authService.isLoggedIn;
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _authService.login(email, password);
    notifyListeners();
    return result;
  }
  
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final result = await _authService.register(username, email, password);
    notifyListeners();
    return result;
  }
  
  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService = HabitService();
  
  Future<void> refresh() async {
    notifyListeners();
  }
}
