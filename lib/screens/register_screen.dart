import 'package:flutter/material.dart';
import 'package:termino/graphql/graphql_auth_service.dart'; // koristi GraphQL verziju

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _registerUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Molimo popunite sva polja')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lozinke se ne podudaraju')),
      );
      return;
    }

    try {
      // Ovdje samo dodaješ korisnika u backend putem GraphQL-a
      await signUpWithGraphQL(
        name: 'Nepoznato',      // ili možeš zatražiti ime na ovom ekranu
        email: email,
        phone: '',
        role: 'user',
      );

      // Ako koristiš Firebase auth za login → onda trebaš i createUserWithEmailAndPassword
      // Ako je samo GraphQL → ovo je dovoljno.

      Navigator.pushReplacementNamed(context, '/user-dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC3F44D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'TERMINO',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontFamily: 'Sofadi One',
                color: Color(0xFFC3F44D),
              ),
            ),
            const SizedBox(height: 64),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white24,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Lozinka',
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white24,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Potvrdi lozinku',
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white24,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                foregroundColor: const Color(0xFF1A434E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Text(
                'Registriraj se',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Sofadi One',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}