import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'user_id')
  final int userId;
  final String username;
  final String email;
  @JsonKey(name: 'password_hash')
  final String? passwordHash;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'last_sync_at')
  final DateTime? lastSyncAt;

  User({
    required this.userId,
    required this.username,
    required this.email,
    this.passwordHash,
    this.createdAt,
    this.lastSyncAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Convert to SQLite map
  Map<String, dynamic> toSqlite() => {
    'user_id': userId,
    'username': username,
    'email': email,
    'password_hash': passwordHash,
    'created_at': createdAt?.toIso8601String(),
    'last_sync_at': lastSyncAt?.toIso8601String(),
  };

  // Create from SQLite map
  factory User.fromSqlite(Map<String, dynamic> map) => User(
    userId: map['user_id'],
    username: map['username'],
    email: map['email'],
    passwordHash: map['password_hash'],
    createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    lastSyncAt: map['last_sync_at'] != null ? DateTime.parse(map['last_sync_at']) : null,
  );
}

