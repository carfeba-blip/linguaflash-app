import 'package:flutter/material.dart';
import 'package:linguaflash/models/card_model.dart';
import 'package:linguaflash/services/api_service.dart';
import 'package:linguaflash/services/sound_service.dart';

class ReviewScreen extends StatefulWidget {
  final List<CardModel> cards;
  const ReviewScreen({super.key, required this.cards});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int currentIndex = 0;
  int correct = 0;
  int incorrect = 0;
  bool finished = false;
  bool loading = true;
  List<String> options = [];
  String? correctAnswer;
  String? selectedAnswer;
  bool? answeredCorrect;
  String? explanation;

  @override
  void initState() {
    super.initState();
    loadQuiz();
  }

  Future<void> loadQuiz() async {
    setState(() {
      loading = true;
      selectedAnswer = null;
      answeredCorrect = null;
      explanation = null;
    });
    final card = widget.cards[currentIndex];
    final data = await ApiService.generateQuiz(
        card.word, card.language, card.translation);
    if (data != null && mounted) {
      setState(() {
        options = List<String>.from(data['options']);
        correctAnswer = data['correct'];
        loading = false;
      });
    } else if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> selectAnswer(String answer) async {
    if (selectedAnswer != null) return;
    final card = widget.cards[currentIndex];
    final isCorrect = answer == correctAnswer;

    if (isCorrect) {
      await SoundService.playCorrect();
      correct++;
      await ApiService.submitReview(card.id, true);
    } else {
      await SoundService.playWrong();
      incorrect++;
      await ApiService.submitReview(card.id, false);
    }

    setState(() {
      selectedAnswer = answer;
      answeredCorrect = isCorrect;
      explanation = card.example ?? 'La respuesta correcta es: $correctAnswer';
    });
  }

  void nextCard() {
    SoundService.playClick();
    if (currentIndex + 1 >= widget.cards.length) {
      setState(() {
        finished = true;
      });
    } else {
      setState(() {
        currentIndex++;
      });
      loadQuiz();
    }
  }

  Color getOptionColor(String option) {
    if (selectedAnswer == null) return Theme.of(context).cardColor;
    if (option == correctAnswer) return Colors.green.shade50;
    if (option == selectedAnswer && !answeredCorrect!)
      return Colors.red.shade50;
    return Theme.of(context).cardColor;
  }

  Color getOptionBorderColor(String option) {
    if (selectedAnswer == null) return Colors.grey.shade200;
    if (option == correctAnswer) return Colors.green;
    if (option == selectedAnswer && !answeredCorrect!) return Colors.red;
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sesión completada')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                Text('${widget.cards.length} tarjetas repasadas',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: [
                      Text('$correct',
                          style: const TextStyle(
                              fontSize: 32,
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                      const Text('Correctas'),
                    ]),
                    Column(children: [
                      Text('$incorrect',
                          style: const TextStyle(
                              fontSize: 32,
                              color: Colors.red,
                              fontWeight: FontWeight.bold)),
                      const Text('Incorrectas'),
                    ]),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final card = widget.cards[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('${currentIndex + 1} / ${widget.cards.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text('$correct',
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
                Text('Generando opciones...',
                    style: TextStyle(color: Colors.grey)),
              ],
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Text(card.language.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.grey,
                                  letterSpacing: 2,
                                  fontSize: 12)),
                          const SizedBox(height: 12),
                          Text(card.word,
                              style: const TextStyle(
                                  fontSize: 36, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('¿Cual es la traducción correcta?',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ...options.map((option) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => selectAnswer(option),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: getOptionColor(option),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: getOptionBorderColor(option),
                                  width: 2),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(option,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center),
                                ),
                                if (selectedAnswer != null &&
                                    option == correctAnswer)
                                  const Icon(Icons.check_circle,
                                      color: Colors.green),
                                if (selectedAnswer != null &&
                                    option == selectedAnswer &&
                                    !answeredCorrect!)
                                  const Icon(Icons.cancel, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                      )),
                  if (selectedAnswer != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: answeredCorrect!
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: answeredCorrect!
                                ? Colors.green.shade200
                                : Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            answeredCorrect! ? '¡Correcto!' : '¡Incorrecto!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  answeredCorrect! ? Colors.green : Colors.red,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(explanation ?? '',
                              style: TextStyle(
                                  color: answeredCorrect!
                                      ? Colors.green.shade700
                                      : Colors.red.shade700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: nextCard,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(currentIndex + 1 >= widget.cards.length
                          ? 'Finalizar'
                          : 'Siguiente palabra'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
    );
  }
}
