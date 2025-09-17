// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Habit _$HabitFromJson(Map<String, dynamic> json) => Habit(
      habitId: json['habit_id'] as int,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      color: json['color'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      repeatFrequency: json['repeat_frequency'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$HabitToJson(Habit instance) => <String, dynamic>{
      'habit_id': instance.habitId,
      'title': instance.title,
      'emoji': instance.emoji,
      'color': instance.color,
      'type': instance.type,
      'category': instance.category,
      'repeat_frequency': instance.repeatFrequency,
      'created_at': instance.createdAt?.toIso8601String(),
    };
