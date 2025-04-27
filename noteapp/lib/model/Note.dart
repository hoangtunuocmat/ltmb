import 'dart:convert';

class Note {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final int priority;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String>? tags;
  final String? color;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
  });

  Note copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': jsonEncode(tags), // Chuyển List<String> thành JSON
      'color': color,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int?,
      userId: json['userId'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      priority: json['priority'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      tags: json['tags'] != null
          ? (jsonDecode(json['tags']) as List<dynamic>).cast<String>()
          : null,
      color: json['color'] as String?,
    );
  }
}