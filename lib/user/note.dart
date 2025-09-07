class Note {
  int? id; // Identifiant unique
  int userId; // Référence à l'utilisateur
  String title; // Titre de la note
  bool isDone; // Statut : terminée ou non
  String createdAt; // Date de création (ISO 8601)
  String? deadline; // Date limite (optionnelle)

  /// 🔧 Constructeur principal
  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.isDone,
    required this.createdAt,
    this.deadline,
  });

  /// 🔁 Conversion en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title.trim(),
      'is_done': isDone ? 1 : 0,
      'created_at': createdAt,
      'deadline': deadline,
    };
  }

  /// 🔁 Création depuis un Map SQLite
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      isDone: map['is_done'] == 1,
      createdAt: map['created_at'],
      deadline: map['deadline'],
    );
  }

  /// 🧪 Vérifie si la note est valide
  bool isValid() => title.trim().isNotEmpty;

  @override
  String toString() {
    return 'Note(id: $id, userId: $userId, title: "$title", isDone: $isDone)';
  }
}
