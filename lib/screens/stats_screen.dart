import 'package:flutter/material.dart';
import 'package:linguaflash/services/api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? stats;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    setState(() {
      loading = true;
    });
    final data = await ApiService.getStats();
    setState(() {
      stats = data;
      loading = false;
    });
  }

  Future<void> confirmResetProgress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar progreso'),
        content: const Text(
            '¿Seguro que quieres borrar todo el progreso? Las tarjetas se conservaran.'),
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
      await ApiService.resetProgress();
      loadStats();
    }
  }

  Future<void> confirmResetCards() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar tarjetas'),
        content: const Text(
            '¿Seguro que quieres borrar TODAS las tarjetas? El progreso se conservara.'),
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
    if (confirm == true) {
      await ApiService.resetCards();
      loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadisticas')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : stats == null
              ? const Center(child: Text('Error al cargar estadisticas'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Tu progreso',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                              child: _StatCard(
                                  label: 'Total repasos',
                                  value: '${stats!['total_reviews']}',
                                  color: Colors.blue)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _StatCard(
                                  label: 'Correctas',
                                  value: '${stats!['correct_reviews']}',
                                  color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _StatCard(
                                  label: 'Incorrectas',
                                  value: '${stats!['incorrect_reviews']}',
                                  color: Colors.red)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _StatCard(
                                  label: 'Precision',
                                  value: '${stats!['accuracy']}%',
                                  color: Colors.purple)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StatCard(
                          label: 'Tarjetas para repasar hoy',
                          value: '${stats!['cards_due_today']}',
                          color: Colors.orange),
                      const SizedBox(height: 32),
                      const Text('Gestion',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: confirmResetProgress,
                        icon: const Icon(Icons.refresh, color: Colors.orange),
                        label: const Text('Reiniciar progreso',
                            style: TextStyle(color: Colors.orange)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: confirmResetCards,
                        icon: const Icon(Icons.delete_sweep, color: Colors.red),
                        label: const Text('Borrar todas las tarjetas',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
