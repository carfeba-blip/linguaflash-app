import 'package:flutter/material.dart';
import 'package:linguaflash/services/api_service.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final wordController = TextEditingController();
  final translationController = TextEditingController();
  final languageController = TextEditingController();
  final exampleController = TextEditingController();
  bool loading = false;
  bool generating = false;
  String? error;

  Future<void> generateWithAI() async {
    if (wordController.text.isEmpty || languageController.text.isEmpty) {
      setState(() {
        error = 'Introduce la palabra y el idioma primero';
      });
      return;
    }
    setState(() {
      generating = true;
      error = null;
    });
    final data = await ApiService.generateWordInfo(
      wordController.text.trim(),
      languageController.text.trim(),
    );
    setState(() {
      generating = false;
    });
    if (data != null) {
      translationController.text = data['definition'];
      exampleController.text = data['example'];
    } else {
      setState(() {
        error = 'Error al generar';
      });
    }
  }

  Future<void> saveCard() async {
    if (wordController.text.isEmpty ||
        translationController.text.isEmpty ||
        languageController.text.isEmpty) {
      setState(() {
        error = 'Rellena los campos obligatorios';
      });
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    final success = await ApiService.createCard(
      wordController.text.trim(),
      translationController.text.trim(),
      languageController.text.trim(),
      exampleController.text.isEmpty ? null : exampleController.text.trim(),
    );
    setState(() {
      loading = false;
    });
    if (success && mounted) {
      Navigator.pop(context);
    } else {
      setState(() {
        error = 'Error al guardar la tarjeta';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva tarjeta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: wordController,
              decoration: const InputDecoration(
                  labelText: 'Palabra *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: languageController,
              decoration: const InputDecoration(
                  labelText: 'Idioma *',
                  border: OutlineInputBorder(),
                  hintText: 'francés, japonés...'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: generating ? null : generateWithAI,
              icon: generating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label: Text(generating ? 'Generando...' : 'Generar palabra'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: translationController,
              decoration: const InputDecoration(
                  labelText: 'Traducción / definición *',
                  border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: exampleController,
              decoration: const InputDecoration(
                  labelText: 'Ejemplo', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : saveCard,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Guardar tarjeta'),
            ),
          ],
        ),
      ),
    );
  }
}
