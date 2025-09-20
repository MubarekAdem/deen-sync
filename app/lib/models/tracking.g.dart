// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tracking _$TrackingFromJson(Map<String, dynamic> json) => Tracking(
      trackingId: json['tracking_id'] as int,
      userHabitId: json['user_habit_id'] as int,
      date: json['date'] as String,
      status: json['status'] as String,
      note: json['note'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TrackingToJson(Tracking instance) => <String, dynamic>{
      'tracking_id': instance.trackingId,
      'user_habit_id': instance.userHabitId,
      'date': instance.date,
      'status': instance.status,
      'note': instance.note,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

