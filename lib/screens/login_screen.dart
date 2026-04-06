import 'package:flutter/material.dart';
import 'package:linguaflash/services/api_service.dart';
import 'package:linguaflash/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool isRegister = false;
  String? error;

  Future<void> submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    bool success;
    if (isRegister) {
      success = await ApiService.register(email, password);
      if (success) success = await ApiService.login(email, password);
    } else {
      success = await ApiService.login(email, password);
    }
    setState(() {
      loading = false;
    });
    if (success && mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() {
        error = isRegister
            ? 'Error al registrar'
            : 'Email o contraseña incorrectos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('⚡', style: TextStyle(fontSize: 36)),
                  SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: 'Lingua',
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: 'Flash',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Aprende vocabulario con IA',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 48),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                    labelText: 'Contraseña', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              if (error != null)
                Text(error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loading ? null : submit,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(isRegister ? 'Registrarse' : 'Iniciar sesión'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  isRegister = !isRegister;
                  error = null;
                }),
                child: Text(isRegister
                    ? '¿Ya tienes cuenta? Inicia sesión'
                    : '¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
