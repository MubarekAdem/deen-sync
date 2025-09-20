import 'package:json_annotation/json_annotation.dart';

part 'habit.g.dart';

@JsonSerializable()
class Habit {
  @JsonKey(name: 'habit_id')
  final int habitId;
  final String title;
  final String emoji;
  final String color;
  final String type; // 'default', 'pre-made', 'custom'
  final String category; // 'Prayers', 'Learning & Dawah', 'Fasting', 'Custom'
  @JsonKey(name: 'repeat_frequency')
  final String repeatFrequency; // 'everyday', 'everyweek', 'dont_repeat'
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Habit({
    required this.habitId,
    required this.title,
    required this.emoji,
    required this.color,
    required this.type,
    required this.category,
    required this.repeatFrequency,
    this.createdAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
  Map<String, dynamic> toJson() => _$HabitToJson(this);

  // Convert to SQLite map
  Map<String, dynamic> toSqlite() => {
    'habit_id': habitId,
    'title': title,
    'emoji': emoji,
    'color': color,
    'type': type,
    'category': category,
    'repeat_frequency': repeatFrequency,
    'created_at': createdAt?.toIso8601String(),
  };

  // Create from SQLite map
  factory Habit.fromSqlite(Map<String, dynamic> map) => Habit(
    habitId: map['habit_id'],
    title: map['title'],
    emoji: map['emoji'],
    color: map['color'],
    type: map['type'],
    category: map['category'],
    repeatFrequency: map['repeat_frequency'],
    createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
  );

  bool get isDefaultPrayer => type == 'default' && category == 'Prayers';
  bool get isPrayerHabit => category == 'Prayers';
}

