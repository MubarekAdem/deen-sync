import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../database/database_helper.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initialize() async {
    await _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getInt('user_id');

    if (token != null && userId != null) {
      _token = token;
      _apiService.setToken(token);
      
      // Load user from local database
      _currentUser = await _dbHelper.getUser(userId);
    }
  }

  Future<void> _saveAuth(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('user_id', user.userId);
    
    _token = token;
    _currentUser = user;
    _apiService.setToken(token);
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    
    _token = null;
    _currentUser = null;
    _apiService.setToken('');
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      // Only allow online registration
      final response = await _apiService.register(username, email, password);
      
      if (response['success']) {
        final userData = response['data'];
        final user = User.fromJson(userData['user']);
        final token = userData['token'];

        // Save user to local database for offline access
        await _dbHelper.insertUser(user);
        
        // Save authentication
        await _saveAuth(token, user);

        return {
          'success': true, 
          'user': user,
          'message': 'Account created successfully'
        };
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Registration requires internet connection. Please check your connection and try again.'
      };
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Try to login with backend first
      final response = await _apiService.login(email, password);
      
      if (response['success']) {
        final userData = response['data'];
        final user = User.fromJson(userData['user']);
        final token = userData['token'];

        // Update user in local database for offline access
        await _dbHelper.insertUser(user);
        
        // Save authentication
        await _saveAuth(token, user);

        return {
          'success': true, 
          'user': user,
          'online': true,
          'message': 'Logged in successfully'
        };
      } else {
        // If backend responds with error, try offline login
        return await _attemptOfflineLogin(email, password);
      }
    } catch (e) {
      // If network error or backend unavailable, try offline login
      return await _attemptOfflineLogin(email, password);
    }
  }

  Future<Map<String, dynamic>> _attemptOfflineLogin(String email, String password) async {
    try {
      final localUser = await _dbHelper.getUserByEmail(email);
      if (localUser != null && localUser.passwordHash == password) {
        _currentUser = localUser;
        return {
          'success': true,
          'user': localUser,
          'offline': true,
          'message': 'Logged in offline. Will sync when connection is available.'
        };
      } else {
        return {'success': false, 'error': 'Invalid email or password'};
      }
    } catch (localError) {
      return {'success': false, 'error': 'Login failed: $localError'};
    }
  }

  Future<void> logout() async {
    await _clearAuth();
  }

  Future<bool> syncUserData() async {
    if (_currentUser == null || _token == null) return false;

    try {
      // Sync user data with backend
      await _apiService.syncFromCloud();
      
      // Update local database with synced data
      // This would involve more complex logic to handle conflicts
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateLastSync() async {
    if (_currentUser == null) return;

    final updatedUser = User(
      userId: _currentUser!.userId,
      username: _currentUser!.username,
      email: _currentUser!.email,
      passwordHash: _currentUser!.passwordHash,
      createdAt: _currentUser!.createdAt,
      lastSyncAt: DateTime.now(),
    );

    await _dbHelper.updateUser(updatedUser);
    _currentUser = updatedUser;
  }
}

