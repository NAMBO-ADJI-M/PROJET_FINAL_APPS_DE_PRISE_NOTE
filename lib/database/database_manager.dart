// 📦 Importation des packages nécessaires
import 'package:sqflite/sqflite.dart'; // Pour la gestion de la base SQLite
import 'package:path/path.dart'; // Pour construire le chemin du fichier de base
import 'package:prise_de_note/user/user.dart'; // Modèle utilisateur
import 'package:prise_de_note/user/note.dart'; // Modèle note

// 🔧 Classe singleton pour gérer la base de données
class DatabaseManager {
  // Instance unique de la classe
  static final DatabaseManager instance = DatabaseManager._init();

  // Référence à la base SQLite
  static Database? _database;

  // Constructeur privé
  DatabaseManager._init();

  /// 📦 Accès à la base de données SQLite
  Future<Database> get database async {
    // Si la base est déjà ouverte, on la retourne
    if (_database != null) return _database!;
    // Sinon, on l'initialise
    _database = await _initDB('prise_de_notes.db');
    return _database!;
  }

  /// 🏗️ Initialisation de la base avec création du fichier
  Future<Database> _initDB(String filePath) async {
    final dbPath = join(await getDatabasesPath(), filePath);
    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  /// 🧱 Création des tables lors de la première ouverture
  Future _createDB(Database db, int version) async {
    // 👤 Table des utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        secret_question TEXT,
        secret_answer TEXT
      )
    ''');

    // 📝 Table des notes liées à un utilisateur
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

  // ────────────────────────────────────────────────
  // 👤 Opérations CRUD pour les utilisateurs
  // ────────────────────────────────────────────────

  /// 🔐 Insertion d’un nouvel utilisateur
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Remplace si doublon
    );
  }

  /// 🔍 Récupération d’un utilisateur par son ID
  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      columns: ['id', 'username', 'password', 'secret_question', 'secret_answer'],
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  /// 🔍 Récupération d’un utilisateur par son nom d’utilisateur
  Future<User?> getUserByUsername(String username) async {
  final db = await database;
  final cleanedUsername = username.trim().toLowerCase();

  final maps = await db.query(
    'users',
    columns: ['id', 'username', 'password', 'secret_question', 'secret_answer'],
    where: 'LOWER(username) = ?',
    whereArgs: [cleanedUsername],
  );

  return maps.isNotEmpty ? User.fromMap(maps.first) : null;
}

  /// ✏️ Mise à jour complète d’un utilisateur
  Future<int> updateUser(User user) async {
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// 🔐 Mise à jour du mot de passe via l’ID
  Future<int> updatePassword(int userId, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// 🔐 Mise à jour du mot de passe via le nom d’utilisateur
  Future<int> updatePasswordByUsername(String username, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  /// 🗑️ Suppression d’un utilisateur
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ────────────────────────────────────────────────
  // 📝 Opérations CRUD pour les notes
  // ────────────────────────────────────────────────

  /// 🆕 Insertion d’une nouvelle note
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

  /// 📋 Récupération de toutes les notes d’un utilisateur
  Future<List<Note>> getNotesByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// 🔍 Récupération d’une note par son ID
  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Note.fromMap(maps.first) : null;
  }

  /// ✏️ Mise à jour d’une note
  Future<int> updateNote(Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// 🗑️ Suppression d’une note
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 🛑 Fermeture propre de la base de données
  Future close() async {
    final db = await database;
    db.close();
  }
}
