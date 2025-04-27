import 'dart:convert';

class Account {
  int? id;
  int userId;
  String username;
  String password;
  String status;
  String lastLogin;
  String createdAt;
  String? email; // Thêm thuộc tính email

  Account({
    this.id,
    required this.userId,
    required this.username,
    required this.password,
    required this.status,
    required this.lastLogin,
    required this.createdAt,
    this.email,
  });

  // Tạo Account từ Map
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      userId: map['userId'],
      username: map['username'],
      password: map['password'],
      status: map['status'],
      lastLogin: map['lastLogin'],
      createdAt: map['createdAt'],
      email: map['email'], // Thêm email
    );
  }

  // Tạo Account từ JSON string
  factory Account.fromJSON(String source) {
    return Account.fromMap(jsonDecode(source));
  }

  // Chuyển đổi Account thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'password': password,
      'status': status,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
      'email': email, // Thêm email
    };
  }

  // Chuyển đổi Account thành JSON string
  String toJSON() {
    return jsonEncode(toMap());
  }

  // Tạo bản sao của Account với một số thuộc tính được cập nhật
  Account copyWith({
    int? id,
    int? userId,
    String? username,
    String? password,
    String? status,
    String? lastLogin,
    String? createdAt,
    String? email,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email, // Thêm email
    );
  }

  @override
  String toString() {
    return 'Account(id: $id, userId: $userId, username: $username, status: $status, lastLogin: $lastLogin, createdAt: $createdAt, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Account &&
        other.id == id &&
        other.userId == userId &&
        other.username == username &&
        other.password == password &&
        other.status == status &&
        other.lastLogin == lastLogin &&
        other.createdAt == createdAt &&
        other.email == email; // Thêm email
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    username.hashCode ^
    password.hashCode ^
    status.hashCode ^
    lastLogin.hashCode ^
    createdAt.hashCode ^
    email.hashCode; // Thêm email
  }
}