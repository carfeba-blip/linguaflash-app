import 'package:flutter/material.dart';
import 'package:linguaflash/services/api_service.dart';
import 'package:linguaflash/services/sound_service.dart';
import 'package:linguaflash/screens/game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final String sourceLang;
  final String targetLang;

  const GameScreen(
      {super.key, required this.sourceLang, required this.targetLang});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final answerController = TextEditingController();
  String? currentWord;
  String? currentHint;
  List<String> usedWords = [];
  int score = 0;
  bool loading = true;
  bool validating = false;
  String? feedback;
  bool? lastCorrect;
  bool _disposed = false;
  int _correctKey = 0;

  @override
  void initState() {
    super.initState();
    loadNextWord();
  }

  @override
  void dispose() {
    _disposed = true;
    answerController.dispose();
    super.dispose();
  }

  Future<void> loadNextWord() async {
    if (_disposed) return;
    setState(() {
      loading = true;
      feedback = null;
      lastCorrect = null;
    });
    answerController.clear();
    final data =
        await ApiService.generateGameWord(widget.sourceLang, usedWords);
    if (!_disposed && mounted && data != null) {
      setState(() {
        currentWord = data['word'];
        currentHint = data['hint'];
        loading = false;
      });
    } else if (!_disposed && mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void exitGame() {
    if (_disposed) return;
    SoundService.playClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Llevas $score puntos. ¿Quieres salir?'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Sortir',
          onPressed: () {
            if (!_disposed && mounted) {
              _disposed = true;
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Future<void> submitAnswer() async {
    if (answerController.text.isEmpty || currentWord == null) return;
    SoundService.playClick();
    setState(() {
      validating = true;
    });

    final result = await ApiService.validateAnswer(
      currentWord!,
      widget.sourceLang,
      widget.targetLang,
      answerController.text.trim(),
    );

    if (_disposed || !mounted) return;

    if (result == null) {
      setState(() {
        validating = false;
      });
      return;
    }

    final correct = result['correct'] as bool;

    await ApiService.createCard(
      currentWord!,
      result['correct_answer'],
      widget.sourceLang,
      result['explanation'],
    );

    if (_disposed || !mounted) return;
    usedWords.add(currentWord!);

    if (correct) {
      await SoundService.playCorrect();
      if (_disposed || !mounted) return;
      setState(() {
        score++;
        lastCorrect = true;
        feedback = result['explanation'];
        validating = false;
        _correctKey++;
      });
      await Future.delayed(const Duration(seconds: 4));
      if (!_disposed && mounted) loadNextWord();
    } else {
      await SoundService.playWrong();
      if (_disposed || !mounted) return;
      final word = currentWord!;
      final answer = result['correct_answer'] as String;
      final explanation = result['explanation'] as String;
      final currentScore = score;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameOverScreen(
              score: currentScore,
              lastWord: word,
              correctAnswer: answer,
              explanation: explanation,
              sourceLang: widget.sourceLang,
              targetLang: widget.targetLang,
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sourceLang} → ${widget.targetLang}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: exitGame,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text('$score',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando palabra...',
                    style: TextStyle(color: Colors.grey)),
              ],
            ))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: lastCorrect == true
                          ? Colors.green.shade50
                          : Theme.of(context).cardColor,
                      border: Border.all(
                        color: lastCorrect == true
                            ? Colors.green
                            : Colors.grey.shade200,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Text(widget.sourceLang.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.grey,
                                  letterSpacing: 2,
                                  fontSize: 12)),
                          const SizedBox(height: 12),
                          Text(currentWord ?? '',
                              style: const TextStyle(
                                  fontSize: 42, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (currentHint != null)
                            Text(currentHint!,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (lastCorrect == true)
                    TweenAnimationBuilder<double>(
                      key: ValueKey(_correctKey),
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) => Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.green.shade300, width: 2),
                          ),
                          child: Row(
                            children: [
                              const Text('😊', style: TextStyle(fontSize: 40)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('¡Correcto!',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(feedback ?? '',
                                        style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (lastCorrect == null) ...[
                    Text('Tradueix al ${widget.targetLang}:',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: answerController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'La traducción...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: validating ? null : submitAnswer,
                        ),
                      ),
                      onSubmitted: (_) => validating ? null : submitAnswer(),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: validating ? null : submitAnswer,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: validating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                  SizedBox(width: 12),
                                  Text('Comprobando...'),
                                ])
                          : const Text('Enviar respuesta'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: exitGame,
                      icon: const Icon(Icons.exit_to_app, color: Colors.red),
                      label: const Text('Abandonar juego',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
