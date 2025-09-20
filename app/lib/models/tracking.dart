import 'package:json_annotation/json_annotation.dart';

part 'tracking.g.dart';

@JsonSerializable()
class Tracking {
  @JsonKey(name: 'tracking_id')
  final int trackingId;
  @JsonKey(name: 'user_habit_id')
  final int userHabitId;
  final String date; // YYYY-MM-DD format
  final String status; // 'not_prayed', 'late', 'on_time', 'in_jemaah', 'completed', 'not_completed'
  final String? note;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Tracking({
    required this.trackingId,
    required this.userHabitId,
    required this.date,
    required this.status,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory Tracking.fromJson(Map<String, dynamic> json) => _$TrackingFromJson(json);
  Map<String, dynamic> toJson() => _$TrackingToJson(this);

  // Convert to SQLite map
  Map<String, dynamic> toSqlite() => {
    'tracking_id': trackingId,
    'user_habit_id': userHabitId,
    'date': date,
    'status': status,
    'note': note,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  // Create from SQLite map
  factory Tracking.fromSqlite(Map<String, dynamic> map) => Tracking(
    trackingId: map['tracking_id'],
    userHabitId: map['user_habit_id'],
    date: map['date'],
    status: map['status'],
    note: map['note'],
    createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
  );

  // Prayer status helpers
  bool get isNotPrayed => status == 'not_prayed';
  bool get isLate => status == 'late';
  bool get isOnTime => status == 'on_time';
  bool get isInJemaah => status == 'in_jemaah';
  bool get isCompleted => status == 'completed';
  bool get isNotCompleted => status == 'not_completed';

  // Status display helpers
  String get displayStatus {
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

  // Status colors for UI
  String get statusColor {
    switch (status) {
      case 'not_prayed': return '#FF6B6B';
      case 'late': return '#FFA726';
      case 'on_time': return '#66BB6A';
      case 'in_jemaah': return '#42A5F5';
      case 'completed': return '#66BB6A';
      case 'not_completed': return '#FF6B6B';
      default: return '#9E9E9E';
    }
  }
}

