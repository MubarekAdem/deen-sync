import '../models/habit.dart';
import '../models/user_habit.dart';
import '../models/tracking.dart';
import '../database/database_helper.dart';
import 'api_service.dart';

class HabitService {
  static final HabitService _instance = HabitService._internal();
  factory HabitService() => _instance;
  HabitService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();

  // Default habits data (matching backend)
  final List<Map<String, dynamic>> _defaultHabitsData = [
    // Default Prayer Habits
    {'habit_id': 1, 'title': 'Fajr', 'emoji': '🌅', 'color': '#FF6B6B', 'type': 'default', 'category': 'Prayers', 'repeat_frequency': 'everyday'},
    {'habit_id': 2, 'title': 'Dhuhr', 'emoji': '☀️', 'color': '#4ECDC4', 'type': 'default', 'category': 'Prayers', 'repeat_frequency': 'everyday'},
    {'habit_id': 3, 'title': 'Asr', 'emoji': '🌤️', 'color': '#45B7D1', 'type': 'default', 'category': 'Prayers', 'repeat_frequency': 'everyday'},
    {'habit_id': 4, 'title': 'Maghrib', 'emoji': '🌇', 'color': '#F7B731', 'type': 'default', 'category': 'Prayers', 'repeat_frequency': 'everyday'},
    {'habit_id': 5, 'title': 'Isha', 'emoji': '🌙', 'color': '#5F27CD', 'type': 'default', 'category': 'Prayers', 'repeat_frequency': 'everyday'},
    
    // Pre-made Learning & Dawah Habits
    {'habit_id': 6, 'title': 'Read Islamic Books', 'emoji': '📚', 'color': '#00D2D3', 'type': 'pre-made', 'category': 'Learning & Dawah', 'repeat_frequency': 'everyday'},
    {'habit_id': 7, 'title': 'Listen Quran', 'emoji': '📖', 'color': '#FF9FF3', 'type': 'pre-made', 'category': 'Learning & Dawah', 'repeat_frequency': 'everyday'},
    {'habit_id': 8, 'title': 'Listen Lectures', 'emoji': '🎧', 'color': '#54A0FF', 'type': 'pre-made', 'category': 'Learning & Dawah', 'repeat_frequency': 'everyday'},
    
    // Pre-made Prayer Habits
    {'habit_id': 9, 'title': 'Tarawih', 'emoji': '🤲', 'color': '#5F27CD', 'type': 'pre-made', 'category': 'Prayers', 'repeat_frequency': 'everyday'},
    {'habit_id': 10, 'title': 'Sunnah', 'emoji': '🕌', 'color': '#10AC84', 'type': 'pre-made', 'category': 'Prayers', 'repeat_frequency': 'everyday'},
    {'habit_id': 11, 'title': 'Witr', 'emoji': '🌟', 'color': '#F79F1F', 'type': 'pre-made', 'category': 'Prayers', 'repeat_frequency': 'everyday'},
    {'habit_id': 12, 'title': 'Ishraq', 'emoji': '🌄', 'color': '#FDA7DF', 'type': 'pre-made', 'category': 'Prayers', 'repeat_frequency': 'everyday'},
    {'habit_id': 13, 'title': 'Tahajjud', 'emoji': '✨', 'color': '#9980FA', 'type': 'pre-made', 'category': 'Prayers', 'repeat_frequency': 'everyday'},
    {'habit_id': 14, 'title': 'Tahiyatul Masjid', 'emoji': '🕊️', 'color': '#12CBC4', 'type': 'pre-made', 'category': 'Prayers', 'repeat_frequency': 'everyday'},
    
    // Pre-made Fasting Habits
    {'habit_id': 15, 'title': 'Monday and Thursday Fasting', 'emoji': '🌙', 'color': '#C44569', 'type': 'pre-made', 'category': 'Fasting', 'repeat_frequency': 'everyweek'},
  ];

  Future<void> initializeDefaultHabits() async {
    try {
      // Check if habits are already initialized
      final existingHabits = await _dbHelper.getAllHabits();
      if (existingHabits.isEmpty) {
        // Insert default habits
        for (final habitData in _defaultHabitsData) {
          final habit = Habit(
            habitId: habitData['habit_id'],
            title: habitData['title'],
            emoji: habitData['emoji'],
            color: habitData['color'],
            type: habitData['type'],
            category: habitData['category'],
            repeatFrequency: habitData['repeat_frequency'],
            createdAt: DateTime.now(),
          );
          await _dbHelper.insertHabit(habit);
        }
      }
    } catch (e) {
      print('Error initializing default habits: $e');
    }
  }

  Future<void> setupDefaultPrayersForUser(int userId) async {
    try {
      // Check if user already has any habits
      final existingUserHabits = await getUserHabits(userId);
      if (existingUserHabits.isNotEmpty) return; // User already has habits, don't add defaults

      // Get the 5 daily prayer habits (habit_id 1-5)
      final dailyPrayerIds = [1, 2, 3, 4, 5]; // Fajr, Dhuhr, Asr, Maghrib, Isha
      
      for (final habitId in dailyPrayerIds) {
        try {
          await addHabitToUser(habitId, userId);
        } catch (e) {
          print('Error adding default prayer habit $habitId: $e');
          // Continue with other prayers even if one fails
        }
      }
    } catch (e) {
      print('Error setting up default prayers for user: $e');
    }
  }

  Future<List<Habit>> getAllHabits() async {
    try {
      // Try to sync from cloud first
      final cloudHabits = await _apiService.getHabits();
      
      // Update local database
      for (final habit in cloudHabits) {
        await _dbHelper.insertHabit(habit);
      }
      
      return await _dbHelper.getAllHabits();
    } catch (e) {
      // Fallback to local habits
      return await _dbHelper.getAllHabits();
    }
  }

  Future<List<Habit>> getAvailableHabits(int userId) async {
    try {
      // Get all habits
      final allHabits = await getAllHabits();
      
      // Get user's current habits
      final userHabits = await getUserHabits(userId);
      final trackedHabitIds = userHabits.map((uh) => uh.habitId).toSet();
      
      // Return habits not currently tracked by user
      return allHabits.where((habit) => !trackedHabitIds.contains(habit.habitId)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserHabit>> getUserHabits(int userId) async {
    try {
      // Try to sync from cloud first
      final cloudUserHabits = await _apiService.getUserHabits();
      
      // Update local database (simplified sync)
      for (final userHabit in cloudUserHabits) {
        try {
          await _dbHelper.insertUserHabit(userHabit);
        } catch (e) {
          // Might already exist
        }
      }
      
      return await _dbHelper.getUserHabits(userId);
    } catch (e) {
      // Fallback to local user habits
      return await _dbHelper.getUserHabits(userId);
    }
  }

  Future<bool> addHabitToUser(int habitId, int userId) async {
    try {
      // Try to add to cloud first
      try {
        await _apiService.addUserHabit(habitId);
      } catch (e) {
        // Continue with local add
      }

      // Add to local database
      final userHabitId = await _dbHelper.getNextId('user_habits', 'user_habit_id');
      final userHabit = UserHabit(
        userHabitId: userHabitId,
        userId: userId,
        habitId: habitId,
        addedAt: DateTime.now(),
      );

      await _dbHelper.insertUserHabit(userHabit);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeHabitFromUser(int habitId, int userId) async {
    try {
      // Try to remove from cloud first
      try {
        await _apiService.removeUserHabit(habitId);
      } catch (e) {
        // Continue with local removal
      }

      // Remove from local database
      await _dbHelper.deleteUserHabit(userId, habitId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Habit> createCustomHabit(String title, String emoji, String color, String repeatFrequency) async {
    try {
      // Try to create in cloud first
      try {
        final cloudHabit = await _apiService.createCustomHabit(title, emoji, color, repeatFrequency);
        await _dbHelper.insertHabit(cloudHabit);
        return cloudHabit;
      } catch (e) {
        // Create locally
        final habitId = await _dbHelper.getNextId('habits', 'habit_id');
        final habit = Habit(
          habitId: habitId,
          title: title,
          emoji: emoji,
          color: color,
          type: 'custom',
          category: 'Custom',
          repeatFrequency: repeatFrequency,
          createdAt: DateTime.now(),
        );

        await _dbHelper.insertHabit(habit);
        return habit;
      }
    } catch (e) {
      throw Exception('Failed to create custom habit: $e');
    }
  }

  Future<bool> deleteCustomHabit(int habitId) async {
    try {
      // Only allow deletion of custom habits
      final habit = await _dbHelper.getHabit(habitId);
      if (habit == null || habit.type != 'custom') {
        return false;
      }

      // Remove from local database (includes related user_habits and tracking)
      await _dbHelper.deleteHabit(habitId);
      
      // Note: In a full implementation, you'd also sync this deletion to the cloud
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logHabitProgress(int habitId, String date, String status, int userId, {String? note}) async {
    try {
      // Find user habit
      final userHabits = await getUserHabits(userId);
      final userHabit = userHabits.firstWhere((uh) => uh.habitId == habitId);

      // Try to log to cloud first
      try {
        await _apiService.logHabitProgress(habitId, date, status, note: note);
      } catch (e) {
        // Continue with local logging
      }

      // Log to local database
      final trackingId = await _dbHelper.getNextId('tracking', 'tracking_id');
      final tracking = Tracking(
        trackingId: trackingId,
        userHabitId: userHabit.userHabitId,
        date: date,
        status: status,
        note: note,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dbHelper.insertTracking(tracking);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Tracking>> getTrackingRecords(int userId, {String? date, int? habitId}) async {
    try {
      // Try to sync from cloud first
      try {
        final cloudTracking = await _apiService.getTrackingRecords(date: date, habitId: habitId);
        
        // Update local database (simplified sync)
        for (final tracking in cloudTracking) {
          await _dbHelper.insertTracking(tracking);
        }
      } catch (e) {
        // Continue with local data
      }
      
      return await _dbHelper.getTrackingRecords(userId, date: date, habitId: habitId);
    } catch (e) {
      // Fallback to local tracking records
      return await _dbHelper.getTrackingRecords(userId, date: date, habitId: habitId);
    }
  }

  Future<Map<int, Tracking>> getTodayTrackingMap(int userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final trackingRecords = await getTrackingRecords(userId, date: today);
    
    final Map<int, Tracking> trackingMap = {};
    final userHabits = await getUserHabits(userId);
    
    for (final tracking in trackingRecords) {
      final userHabit = userHabits.firstWhere((uh) => uh.userHabitId == tracking.userHabitId);
      trackingMap[userHabit.habitId] = tracking;
    }
    
    return trackingMap;
  }

  List<String> getPrayerStatusOptions() {
    return ['not_prayed', 'late', 'on_time', 'in_jemaah'];
  }

  List<String> getHabitStatusOptions() {
    return ['not_completed', 'completed'];
  }

  String getStatusDisplayName(String status) {
    switch (status) {
      case 'not_prayed': return 'Not Prayed';
      case 'late': return 'Late';
      case 'on_time': return 'On Time';
      case 'in_jemaah': return 'In Jemaah';
      case 'completed': return 'Completed';
      case 'not_completed': return 'Not Completed';
      default: return status;
    }
  }
}

