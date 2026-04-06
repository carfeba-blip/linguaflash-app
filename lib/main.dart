import 'package:flutter/material.dart';
import 'package:linguaflash/screens/login_screen.dart';
import 'package:linguaflash/services/api_service.dart';
import 'package:linguaflash/screens/home_screen.dart';

void main() {
  runApp(const LinguaFlashApp());
}

class LinguaFlashApp extends StatelessWidget {
  const LinguaFlashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinguaFlash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool loading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final token = await ApiService.getToken();
    setState(() {
      isLoggedIn = token != null;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
