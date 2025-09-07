import 'package:flutter/material.dart';
import 'package:prise_de_note/database/database_manager.dart';
import 'package:prise_de_note/user/user.dart';
import 'package:prise_de_note/widgets/header_image.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _customAnswerController = TextEditingController();

  final List<String> _questions = [
    "Quel est le nom de votre premier animal ?",
    "Quelle est votre ville de naissance ?",
    "Quel est le prénom de votre meilleur ami d’enfance ?",
    "Quel est le nom de votre école primaire ?",
  ];

  final List<String> _answers = [
    "Lomé",
    "Tigre",
    "Koffi",
    "Étoile",
    "Autre",
  ];

  String? _selectedQuestion;
  String? _selectedAnswer;
  bool _isRegistering = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _customAnswerController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        content: Center(child: Text(message, textAlign: TextAlign.center)),
      ),
    );
  }

  Future<void> _registerUser() async {
    if (_isRegistering || !_formKey.currentState!.validate()) return;

    setState(() => _isRegistering = true);

    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final question = _selectedQuestion;
    final answer = _selectedAnswer == "Autre"
        ? _customAnswerController.text.trim()
        : _selectedAnswer;

    try {
      final existingUser = await DatabaseManager.instance.getUserByUsername(username);
      if (!mounted) return;

      if (existingUser != null) {
        _showMessage("Ce nom d'utilisateur existe déjà");
        return;
      }

      if (question == null || answer == null || answer.isEmpty) {
        _showMessage("Veuillez choisir une question secrète et y répondre");
        return;
      }

      final newUser = User(
        username: username,
        password: password,
        secretQuestion: question,
        secretAnswer: answer,
      );

      await DatabaseManager.instance.insertUser(newUser);

      if (!mounted) return;

      Navigator.pop(context); // Retour à l'écran précédent
      await Future.delayed(const Duration(milliseconds: 300));
      _showMessage("✅ Inscription réussie");
    } catch (e) {
      if (!mounted) return;
      _showMessage("Erreur : $e");
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 20,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            children: [
              const HeaderImage(),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Nom d'utilisateur",
                        prefixIcon: Icon(Icons.person_outline, color: Colors.blue),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Mot de passe",
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue),
                      ),
                      validator: (v) => v != null && v.length >= 6 ? null : "Min. 6 caractères requis",
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirmer le mot de passe",
                        prefixIcon: Icon(Icons.lock_reset, color: Colors.blue),
                      ),
                      validator: (v) => v == _passwordController.text ? null : "Les mots de passe ne correspondent pas",
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      items: _questions.map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
                      onChanged: (val) => setState(() => _selectedQuestion = val),
                      decoration: const InputDecoration(
                        labelText: "Question secrète",
                        prefixIcon: Icon(Icons.help_outline, color: Colors.blue),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Sélection requise" : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      items: _answers.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAnswer = val;
                          if (val != "Autre") _customAnswerController.clear();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Réponse secrète",
                        prefixIcon: Icon(Icons.vpn_key_outlined, color: Colors.blue),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Sélection requise" : null,
                    ),
                    if (_selectedAnswer == "Autre") ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _customAnswerController,
                        decoration: const InputDecoration(
                          labelText: "Réponse personnalisée",
                          prefixIcon: Icon(Icons.edit_note, color: Colors.blue),
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Veuillez entrer une réponse" : null,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.login, color: Colors.white),
                          onPressed: _isRegistering ? null : _registerUser,
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          label: _isRegistering
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text("S'inscrire"),
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
