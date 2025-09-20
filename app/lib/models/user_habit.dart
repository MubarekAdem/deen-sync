import 'package:json_annotation/json_annotation.dart';
import 'habit.dart';

part 'user_habit.g.dart';

@JsonSerializable()
class UserHabit {
  @JsonKey(name: 'user_habit_id')
  final int userHabitId;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'habit_id')
  final int habitId;
  @JsonKey(name: 'added_at')
  final DateTime? addedAt;
  final Habit? habit; // Populated when fetching with habit details

  UserHabit({
    required this.userHabitId,
    required this.userId,
    required this.habitId,
    this.addedAt,
    this.habit,
  });

  factory UserHabit.fromJson(Map<String, dynamic> json) => _$UserHabitFromJson(json);
  Map<String, dynamic> toJson() => _$UserHabitToJson(this);

  // Convert to SQLite map
  Map<String, dynamic> toSqlite() => {
    'user_habit_id': userHabitId,
    'user_id': userId,
    'habit_id': habitId,
    'added_at': addedAt?.toIso8601String(),
  };

  // Create from SQLite map
  factory UserHabit.fromSqlite(Map<String, dynamic> map) => UserHabit(
    userHabitId: map['user_habit_id'],
    userId: map['user_id'],
    habitId: map['habit_id'],
    addedAt: map['added_at'] != null ? DateTime.parse(map['added_at']) : null,
  );
}

