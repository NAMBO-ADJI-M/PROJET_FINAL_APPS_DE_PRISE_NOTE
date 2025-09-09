import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:prise_de_note/user/user.dart';
import 'package:prise_de_note/user/note.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._init();
  static Database? _database;

  // 🔐 Utilisateur connecté (en mémoire)
  User? _connectedUser;

  DatabaseManager._init();

  // 📦 Accès à la base SQLite
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('prise_de_notes.db');
    return _database!;
  }

  // 🏗️ Initialisation de la base
  Future<Database> _initDB(String filePath) async {
    final dbPath = join(await getDatabasesPath(), filePath);
    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  // 🧱 Création des tables
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        secret_question TEXT,
        secret_answer TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        is_done INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        deadline TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // ────────────────────────────────
  // 👤 Gestion des utilisateurs
  // ────────────────────────────────

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final cleanedUsername = username.trim().toLowerCase();
    final maps = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [cleanedUsername],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> updatePassword(int userId, String newPassword) async {
    final db = await database;
    return db.update('users', {'password': newPassword}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> updatePasswordByUsername(String username, String newPassword) async {
    final db = await database;
    return db.update('users', {'password': newPassword}, where: 'username = ?', whereArgs: [username]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // 🔐 Gestion de l’utilisateur connecté
  void setConnectedUser(User user) {
    _connectedUser = user;
  }

  Future<User?> getConnectedUser() async {
    return _connectedUser;
  }

  // ────────────────────────────────
  // 📝 Gestion des notes
  // ────────────────────────────────

  Future<Note> insertNote(Note note) async {
    final db = await database;
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      userId: note.userId,
      title: note.title,
      isDone: note.isDone,
      createdAt: note.createdAt,
      deadline: note.deadline,
    );
  }

  Future<List<Note>> getNotesByUserId(int userId) async {
    final db = await database;
    final maps = await db.query('notes', where: 'user_id = ?', whereArgs: [userId]);
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Note.fromMap(maps.first) : null;
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
