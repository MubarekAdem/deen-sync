// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserHabit _$UserHabitFromJson(Map<String, dynamic> json) => UserHabit(
      userHabitId: json['user_habit_id'] as int,
      userId: json['user_id'] as int,
      habitId: json['habit_id'] as int,
      addedAt: json['added_at'] == null
          ? null
          : DateTime.parse(json['added_at'] as String),
      habit: json['habit'] == null
          ? null
          : Habit.fromJson(json['habit'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserHabitToJson(UserHabit instance) => <String, dynamic>{
      'user_habit_id': instance.userHabitId,
      'user_id': instance.userId,
      'habit_id': instance.habitId,
      'added_at': instance.addedAt?.toIso8601String(),
      'habit': instance.habit,
    };
