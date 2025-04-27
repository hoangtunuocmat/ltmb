import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:noteapp/model/Note.dart';

class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        priority INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        modifiedAt TEXT NOT NULL,
        tags TEXT,
        color TEXT
      )
    ''');
  }

  Future<Note> createNote(Note note) async {
    final db = await instance.database;
    final id = await db.insert('notes', {
      'userId': note.userId,
      'title': note.title,
      'content': note.content,
      'priority': note.priority,
      'createdAt': note.createdAt.toIso8601String(),
      'modifiedAt': note.modifiedAt.toIso8601String(),
      'tags': jsonEncode(note.tags), // Chuyển List<String> thành JSON
      'color': note.color,
    });
    return note.copyWith(id: id);
  }

  Future<Note> updateNote(Note note) async {
    final db = await instance.database;
    await db.update(
      'notes',
      {
        'userId': note.userId,
        'title': note.title.toString(), // Đảm bảo là String
        'content': note.content.toString(), // Đảm bảo là String
        'priority': note.priority, // Đảm bảo là Integer
        'createdAt': note.createdAt.toIso8601String(),
        'modifiedAt': note.modifiedAt.toIso8601String(),
        'tags': jsonEncode(note.tags), // Chuyển List<String> thành JSON
        'color': note.color,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    return note;
  }

  Future<Note?> getNote(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Note>> getAllNotes(int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((json) => Note.fromJson(json)).toList();
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}