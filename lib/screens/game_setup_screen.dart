import 'package:flutter/material.dart';
import 'package:linguaflash/screens/game_screen.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final sourceController = TextEditingController(text: 'Inglés');
  final targetController = TextEditingController(text: 'Español');

  final List<String> suggestions = [
    'Español',
    'Inglés',
    'Francés',
    'Alemán',
    'Italiano',
    'Portugués',
    'Japonés',
    'Chino',
    'Catalan'
  ];

  void startGame() {
    if (sourceController.text.isEmpty || targetController.text.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          sourceLang: sourceController.text.trim(),
          targetLang: targetController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo juego')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Escoge los idiomas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Traducir las palabras. El juego acaba cuando falles.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text('Idioma de las palabras',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map((s) {
                final selected = sourceController.text == s;
                return GestureDetector(
                  onTap: () => setState(() => sourceController.text = s),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? Colors.deepPurple : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            selected ? Colors.deepPurple : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey.shade700,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: sourceController,
              decoration: const InputDecoration(
                labelText: 'O escribe otro idioma',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.translate),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            const Text('Idioma al que traducir',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map((s) {
                final selected = targetController.text == s;
                return GestureDetector(
                  onTap: () => setState(() => targetController.text = s),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? Colors.deepPurple : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            selected ? Colors.deepPurple : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey.shade700,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: targetController,
              decoration: const InputDecoration(
                labelText: 'O escribe otro idioma',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: startGame,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Empezar juego'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
