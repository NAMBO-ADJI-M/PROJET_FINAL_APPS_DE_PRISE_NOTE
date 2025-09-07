import 'package:flutter/material.dart';
import 'package:prise_de_note/database/database_manager.dart';
import 'package:prise_de_note/screens/main_screen_page.dart';
import 'package:prise_de_note/screens/forgotpasswordscreen.dart';
import 'package:prise_de_note/widgets/header_image.dart';
import 'package:prise_de_note/widgets/sign_up_prompt.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _focusNodePassword = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _focusNodePassword.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text;

    try {
      final user = await DatabaseManager.instance.getUserByUsername(username);

      if (!mounted) return;

      if (user == null) {
        _showErrorSnackBar('Nom d’utilisateur introuvable');
      } else if (password == user.password) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MainPageScreen(currentUser: user)),
        );
      } else {
        _showErrorSnackBar('Mot de passe incorrect');
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Erreur : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        content: Center(child: Text(message, textAlign: TextAlign.center)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes', style: TextStyle(fontWeight: FontWeight.w400)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              const HeaderImage(),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nom d\'utilisateur',
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        border: UnderlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_focusNodePassword),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Veuillez entrer votre nom d’utilisateur' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
  controller: _passwordController,
  focusNode: _focusNodePassword,
  obscureText: _obscurePassword,
  decoration: InputDecoration(
    labelText: 'Mot de passe',
    prefixIcon: const Icon(Icons.lock, color: Colors.blue),
    suffixIcon: IconButton(
      icon: Icon(
        _obscurePassword ? Icons.visibility_off : Icons.visibility,
        color: Colors.blue,
      ),
      onPressed: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
    ),
    border: const UnderlineInputBorder(),
  ),
  validator: (value) =>
      value == null || value.isEmpty ? 'Veuillez entrer votre mot de passe' : null,
),

                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.help_outline, color: Colors.blue),
                        label: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: screenWidth < 400 ? screenWidth * 0.7 : 200,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitLogin,
                          icon: const Icon(Icons.login, color: Colors.white),
                          label: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Se connecter'),
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SignupPrompt(),
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
