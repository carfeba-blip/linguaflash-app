import 'package:flutter/material.dart';
import 'package:linguaflash/services/api_service.dart';
import 'package:linguaflash/models/card_model.dart';
import 'package:linguaflash/screens/add_card_screen.dart';
import 'package:linguaflash/screens/review_screen.dart';
import 'package:linguaflash/screens/stats_screen.dart';
import 'package:linguaflash/screens/login_screen.dart';
import 'package:linguaflash/screens/game_setup_screen.dart';
import 'package:linguaflash/services/sound_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CardModel> cards = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  Future<void> loadCards() async {
    setState(() {
      loading = true;
    });
    final data = await ApiService.getCards();
    setState(() {
      cards = data.map((c) => CardModel.fromJson(c)).toList();
      loading = false;
    });
  }

  Future<void> deleteCard(int id) async {
    SoundService.playClick();
    await ApiService.deleteCard(id);
    loadCards();
  }

  Future<void> confirmDelete(CardModel card) async {
    SoundService.playClick();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar tarjeta'),
        content: Text('Seguro que quieres borrar "${card.word}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Borrar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) deleteCard(card.id);
  }

  Future<void> confirmReset() async {
    SoundService.playClick();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar todo'),
        content: const Text(
            'Seguro que quieres borrar TODAS las tarjetas y el progreso? Esta accion no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Reiniciar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.resetAll(cards.map((c) => c.id).toList());
      loadCards();
    }
  }

  Future<void> logout() async {
    SoundService.playClick();
    await ApiService.deleteToken();
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚡', style: TextStyle(fontSize: 22)),
            SizedBox(width: 4),
            Text('Lingua', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Flash',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.amber)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              SoundService.playClick();
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: confirmReset,
            tooltip: 'Reiniciar tarjetas',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : cards.isEmpty
              ? const Center(
                  child: Text(
                      'No tienes tarjetas aun.\nPulsa + para añadir una o Jugar para empezar.',
                      textAlign: TextAlign.center))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(card.word,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(card.translation),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(card.language,
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDelete(card),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'game',
            onPressed: () {
              SoundService.playClick();
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GameSetupScreen()))
                  .then((_) => loadCards());
            },
            icon: const Icon(Icons.sports_esports),
            label: const Text('Jugar'),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          if (cards.isNotEmpty)
            FloatingActionButton.extended(
              heroTag: 'review',
              onPressed: () {
                SoundService.playClick();
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ReviewScreen(cards: cards)))
                    .then((_) => loadCards());
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Repasar'),
            ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              SoundService.playClick();
              Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddCardScreen()))
                  .then((_) => loadCards());
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
