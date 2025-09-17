import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/habit.dart';
import '../models/user_habit.dart';
import '../models/tracking.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'deen_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT,
        created_at TEXT,
        last_sync_at TEXT
      )
    ''');

    // Habits table
    await db.execute('''
      CREATE TABLE habits (
        habit_id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        emoji TEXT NOT NULL,
        color TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        repeat_frequency TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    // User habits table
    await db.execute('''
      CREATE TABLE user_habits (
        user_habit_id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        habit_id INTEGER NOT NULL,
        added_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (user_id),
        FOREIGN KEY (habit_id) REFERENCES habits (habit_id),
        UNIQUE(user_id, habit_id)
      )
    ''');

    // Tracking table
    await db.execute('''
      CREATE TABLE tracking (
        tracking_id INTEGER PRIMARY KEY,
        user_habit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        note TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_habit_id) REFERENCES user_habits (user_habit_id),
        UNIQUE(user_habit_id, date)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_user_habits_user_id ON user_habits(user_id)');
    await db.execute('CREATE INDEX idx_tracking_user_habit_id ON tracking(user_habit_id)');
    await db.execute('CREATE INDEX idx_tracking_date ON tracking(date)');
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toSqlite());
  }

  Future<User?> getUser(int userId) async {
    final db = await database;
    final maps = await db.query('users', where: 'user_id = ?', whereArgs: [userId]);
    if (maps.isNotEmpty) {
      return User.fromSqlite(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromSqlite(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toSqlite(), where: 'user_id = ?', whereArgs: [user.userId]);
  }

  // Habit operations
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toSqlite(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final maps = await db.query('habits', orderBy: 'habit_id ASC');
    return maps.map((map) => Habit.fromSqlite(map)).toList();
  }

  Future<Habit?> getHabit(int habitId) async {
    final db = await database;
    final maps = await db.query('habits', where: 'habit_id = ?', whereArgs: [habitId]);
    if (maps.isNotEmpty) {
      return Habit.fromSqlite(maps.first);
    }
    return null;
  }

  Future<int> deleteHabit(int habitId) async {
    final db = await database;
    // First delete related tracking records
    await db.rawDelete('''
      DELETE FROM tracking 
      WHERE user_habit_id IN (
        SELECT user_habit_id FROM user_habits WHERE habit_id = ?
      )
    ''', [habitId]);
    // Then delete user habits
    await db.delete('user_habits', where: 'habit_id = ?', whereArgs: [habitId]);
    // Finally delete the habit
    return await db.delete('habits', where: 'habit_id = ?', whereArgs: [habitId]);
  }

  // User habit operations
  Future<int> insertUserHabit(UserHabit userHabit) async {
    final db = await database;
    return await db.insert('user_habits', userHabit.toSqlite());
  }

  Future<List<UserHabit>> getUserHabits(int userId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT uh.*, h.*
      FROM user_habits uh
      JOIN habits h ON uh.habit_id = h.habit_id
      WHERE uh.user_id = ?
      ORDER BY h.habit_id ASC
    ''', [userId]);
    
    return maps.map((map) {
      final userHabit = UserHabit.fromSqlite(map);
      final habit = Habit.fromSqlite(map);
      return UserHabit(
        userHabitId: userHabit.userHabitId,
        userId: userHabit.userId,
        habitId: userHabit.habitId,
        addedAt: userHabit.addedAt,
        habit: habit,
      );
    }).toList();
  }

  Future<int> deleteUserHabit(int userId, int habitId) async {
    final db = await database;
    // First delete related tracking records
    await db.rawDelete('''
      DELETE FROM tracking 
      WHERE user_habit_id IN (
        SELECT user_habit_id FROM user_habits 
        WHERE user_id = ? AND habit_id = ?
      )
    ''', [userId, habitId]);
    // Then delete the user habit
    return await db.delete('user_habits', where: 'user_id = ? AND habit_id = ?', whereArgs: [userId, habitId]);
  }

  // Tracking operations
  Future<int> insertTracking(Tracking tracking) async {
    final db = await database;
    return await db.insert('tracking', tracking.toSqlite(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Tracking>> getTrackingRecords(int userId, {String? date, int? habitId}) async {
    final db = await database;
    
    String query = '''
      SELECT t.*
      FROM tracking t
      JOIN user_habits uh ON t.user_habit_id = uh.user_habit_id
      WHERE uh.user_id = ?
    ''';
    
    List<dynamic> args = [userId];
    
    if (date != null) {
      query += ' AND t.date = ?';
      args.add(date);
    }
    
    if (habitId != null) {
      query += ' AND uh.habit_id = ?';
      args.add(habitId);
    }
    
    query += ' ORDER BY t.date DESC, uh.habit_id ASC';
    
    final maps = await db.rawQuery(query, args);
    return maps.map((map) => Tracking.fromSqlite(map)).toList();
  }

  Future<Tracking?> getTracking(int userHabitId, String date) async {
    final db = await database;
    final maps = await db.query('tracking', 
        where: 'user_habit_id = ? AND date = ?', 
        whereArgs: [userHabitId, date]);
    if (maps.isNotEmpty) {
      return Tracking.fromSqlite(maps.first);
    }
    return null;
  }

  Future<int> updateTracking(Tracking tracking) async {
    final db = await database;
    return await db.update('tracking', tracking.toSqlite(), 
        where: 'tracking_id = ?', whereArgs: [tracking.trackingId]);
  }

  // Utility methods
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('tracking');
    await db.delete('user_habits');
    await db.delete('habits');
    await db.delete('users');
  }

  Future<int> getNextId(String table, String column) async {
    final db = await database;
    final result = await db.rawQuery('SELECT MAX($column) as max_id FROM $table');
    final maxId = result.first['max_id'] as int?;
    return (maxId ?? 0) + 1;
  }
}
