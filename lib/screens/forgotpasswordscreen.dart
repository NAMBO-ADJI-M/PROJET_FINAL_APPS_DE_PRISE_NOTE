import 'package:flutter/material.dart';
import 'package:prise_de_note/database/database_manager.dart';
import 'package:prise_de_note/user/user.dart';
import 'package:prise_de_note/widgets/header_image.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _newPasswordController = TextEditingController();

  List<String> _questions = [];
  final List<String> _answers = ["Lomé", "Tigre", "Koffi", "Étoile", "Autre"];

  String? _selectedQuestion;
  String? _selectedAnswer;
  String? _customAnswer;
  bool _isVerified = false;
  String? _error;

  bool _obscurePassword = true; // 👁️ état de visualisation du mot de passe
  User? _cachedUser;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    _questions = [
      "Quel est le nom de votre premier animal ?",
      "Quelle est votre ville de naissance ?",
      "Quel est le prénom de votre meilleur ami d'enfance ?",
      "Quel est le nom de votre école primaire ?",
    ];
    setState(() {});
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final username = _usernameController.text.trim();
    _cachedUser = await DatabaseManager.instance.getUserByUsername(username);
  }

  Future<void> _verifyIdentity() async {
    await _loadUserData();

    if (!mounted || _cachedUser == null) {
      setState(() => _showSnack("Utilisateur introuvable."));
      return;
    }

    final question = _selectedQuestion?.toLowerCase();
    final answer =
        (_selectedAnswer == "Autre" ? _customAnswer : _selectedAnswer)
            ?.toLowerCase();

    final storedQuestion = _cachedUser!.secretQuestion?.toLowerCase();
    final storedAnswer = _cachedUser!.secretAnswer?.toLowerCase();

    if (storedQuestion == question && storedAnswer == answer) {
      setState(() {
        _isVerified = true;
        _error = null;
      });
      _showSnack("✅ Identité vérifiée");
    } else {
      setState(() {
        _showSnack("Question ou réponse incorrecte.");
      });
    }
  }

  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();

    if (_cachedUser == null || _cachedUser!.id == null) {
      _showSnack("Erreur : utilisateur non chargé.");
      return;
    }

    await DatabaseManager.instance.updatePassword(
      _cachedUser!.id!,
      newPassword,
    );

    if (!mounted) return;
    _showSnack("🔐 Mot de passe mis à jour");
    Navigator.pop(context);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isVerified) {
      await _resetPassword();
    } else {
      await _verifyIdentity();
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(message)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _errorMessage(String? error) {
    return error != null
        ? Text(error, style: const TextStyle(color: Colors.red))
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔐 Mot de passe oublié"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const HeaderImage(),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _errorMessage(_error),

                    // 👤 Nom d'utilisateur
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Nom d'utilisateur",
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Colors.blue,
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Champ requis"
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ❓ Question secrète
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedQuestion,
                      items: _questions
                          .map(
                            (q) => DropdownMenuItem(value: q, child: Text(q)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedQuestion = val),
                      decoration: const InputDecoration(
                        labelText: "Question secrète",
                        prefixIcon: Icon(
                          Icons.help_outline,
                          color: Colors.blue,
                        ),
                      ),
                      validator: (value) =>
                          (value == null) ? "Sélection requise" : null,
                    ),
                    const SizedBox(height: 16),

                    // 🗝️ Réponse secrète
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedAnswer,
                      items: _answers
                          .map(
                            (a) => DropdownMenuItem(value: a, child: Text(a)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedAnswer = val),
                      decoration: const InputDecoration(
                        labelText: "Réponse secrète",
                        prefixIcon: Icon(
                          Icons.vpn_key_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      validator: (value) =>
                          (value == null) ? "Sélection requise" : null,
                    ),

                    // ✍️ Réponse personnalisée
                    if (_selectedAnswer == "Autre") ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Réponse personnalisée",
                          prefixIcon: Icon(Icons.edit_note, color: Colors.blue),
                        ),
                        onChanged: (val) => _customAnswer = val,
                        validator: (value) {
                          if (_selectedAnswer == "Autre" &&
                              (value == null || value.isEmpty)) {
                            return "Veuillez entrer une réponse";
                          }
                          return null;
                        },
                      ),
                    ],

                    // 🔒 Nouveau mot de passe avec icône 👁️
                    if (_isVerified) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Nouveau mot de passe",
                          prefixIcon: const Icon(
                            Icons.lock_reset,
                            color: Colors.blue,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) =>
                            (value != null && value.length >= 6)
                            ? null
                            : "Min. 6 caractères requis",
                      ),
                    ],

                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          onPressed: _handleSubmit,
                          label: Text(
                            _isVerified ? "🔄 Réinitialiser" : "✅ Vérifier",
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
