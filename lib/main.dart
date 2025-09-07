import 'package:flutter/material.dart';
import 'package:prise_de_note/screens/login_screen.dart';

void main() => runApp(MonApplication());

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'poppins'),
      home: LoginScreen(),
    );
  }
}
