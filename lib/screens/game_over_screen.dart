import 'package:flutter/material.dart';
import 'package:linguaflash/screens/game_setup_screen.dart';
import 'package:linguaflash/screens/home_screen.dart';

class GameOverScreen extends StatelessWidget {
  final int score;
  final String lastWord;
  final String correctAnswer;
  final String explanation;
  final String sourceLang;
  final String targetLang;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.lastWord,
    required this.correctAnswer,
    required this.explanation,
    required this.sourceLang,
    required this.targetLang,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.sentiment_dissatisfied,
                  size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text('Juego terminado',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(width: 8),
                  Text('$score puntos',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('La palabra que has fallado:',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(lastWord,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Respuesta correcta:',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(correctAnswer,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(explanation,
                          style: const TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                  'La palabra se ha guardado en tus tarjetas para repasar.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const GameSetupScreen())),
                icon: const Icon(Icons.replay),
                label: const Text('Jugar de nuevo'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen())),
                icon: const Icon(Icons.home),
                label: const Text('Volver al inicio'),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
