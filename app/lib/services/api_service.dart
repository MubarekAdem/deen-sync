import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/habit.dart';
import '../models/user_habit.dart';
import '../models/tracking.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api'; // Change this to your actual backend URL
  
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Authentication
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  // Habits
  Future<List<Habit>> getHabits() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/habits'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((json) => Habit.fromJson(json))
            .toList();
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch habits');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Habit> createCustomHabit(String title, String emoji, String color, String repeatFrequency) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/habits'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'emoji': emoji,
          'color': color,
          'repeat_frequency': repeatFrequency,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return Habit.fromJson(data['data']);
      } else {
        throw Exception(data['error'] ?? 'Failed to create habit');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // User Habits
  Future<List<UserHabit>> getUserHabits() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-habits'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((json) => UserHabit.fromJson(json))
            .toList();
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch user habits');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<UserHabit> addUserHabit(int habitId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user-habits'),
        headers: _headers,
        body: jsonEncode({
          'habit_id': habitId,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return UserHabit.fromJson(data['data']);
      } else {
        throw Exception(data['error'] ?? 'Failed to add habit');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> removeUserHabit(int habitId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user-habits'),
        headers: _headers,
        body: jsonEncode({
          'habit_id': habitId,
        }),
      );

      final data = jsonDecode(response.body);
      if (!data['success']) {
        throw Exception(data['error'] ?? 'Failed to remove habit');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Tracking
  Future<List<Tracking>> getTrackingRecords({String? date, int? habitId}) async {
    try {
      String url = '$baseUrl/tracking';
      List<String> params = [];
      
      if (date != null) {
        params.add('date=$date');
      }
      if (habitId != null) {
        params.add('habit_id=$habitId');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((json) => Tracking.fromJson(json))
            .toList();
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch tracking records');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Tracking> logHabitProgress(int habitId, String date, String status, {String? note}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tracking'),
        headers: _headers,
        body: jsonEncode({
          'habit_id': habitId,
          'date': date,
          'status': status,
          'note': note,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return Tracking.fromJson(data['data']);
      } else {
        throw Exception(data['error'] ?? 'Failed to log habit progress');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Sync operations
  Future<void> syncToCloud({
    List<User>? users,
    List<Habit>? habits,
    List<UserHabit>? userHabits,
    List<Tracking>? trackingRecords,
  }) async {
    // This would implement bulk sync operations
    // For now, we'll sync individual records as needed
    try {
      // Sync user habits
      if (userHabits != null) {
        for (final userHabit in userHabits) {
          try {
            await addUserHabit(userHabit.habitId);
          } catch (e) {
            // Habit might already exist, continue with others
          }
        }
      }

      // Sync tracking records
      if (trackingRecords != null) {
        for (final tracking in trackingRecords) {
          try {
            // We need to get the habit_id from user_habit_id
            // This is a simplified approach - in a real app, you'd want more robust sync logic
            await logHabitProgress(
              tracking.userHabitId, // This would need proper mapping
              tracking.date,
              tracking.status,
              note: tracking.note,
            );
          } catch (e) {
            // Continue with other records
          }
        }
      }
    } catch (e) {
      throw Exception('Sync failed: $e');
    }
  }

  Future<Map<String, dynamic>> syncFromCloud() async {
    try {
      final habits = await getHabits();
      final userHabits = await getUserHabits();
      final trackingRecords = await getTrackingRecords();

      return {
        'habits': habits,
        'userHabits': userHabits,
        'trackingRecords': trackingRecords,
      };
    } catch (e) {
      throw Exception('Sync from cloud failed: $e');
    }
  }
}
