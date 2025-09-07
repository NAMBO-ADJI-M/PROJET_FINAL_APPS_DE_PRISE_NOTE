class User {
  final int? id;
  final String username;
  final String password; // ⚠️ Stocké en clair (à sécuriser plus tard)
  final String? secretQuestion;
  final String? secretAnswer;

  /// 🔧 Constructeur principal
  User({
    this.id,
    required this.username,
    required this.password,
    this.secretQuestion,
    this.secretAnswer,
  });

  /// 🔁 Conversion en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username.trim(),
      'password': password,
      'secret_question': secretQuestion?.trim(),
      'secret_answer': secretAnswer?.trim(),
    };
  }

  /// 🔁 Création depuis un Map SQLite
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      secretQuestion: map['secret_question'],
      secretAnswer: map['secret_answer'],
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username)';
  }
}
