import 'package:flutter/material.dart';

import '../app/discovery_controller.dart';
import '../app/theme.dart';
import '../models/estande.dart';
import 'scanner_screen.dart';

class StandScreen extends StatelessWidget {
  const StandScreen({super.key, required this.stand, required this.controller});
  final Estande stand;
  final DiscoveryController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final current = controller.stands
          .where((item) => item.id == stand.id)
          .firstOrNull;
      final value = current ?? stand;
      final visited = controller.visited.contains(stand.id);
      final inactive =
          current == null &&
          !controller.loading &&
          controller.standError == null;
      return Scaffold(
        appBar: AppBar(title: const Text('Sua próxima descoberta')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: ListView(
                padding: const EdgeInsets.all(26),
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0DF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.hub_outlined,
                      size: 80,
                      color: forest,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    value.nome,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    value.descricao,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.place_outlined, color: forest),
                    title: const Text('Onde encontrar'),
                    subtitle: Text(value.localizacao),
                  ),
                  const SizedBox(height: 22),
                  if (visited)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: forest),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Descoberta registrada! Você já visitou este estande.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (inactive)
                    const Text(
                      'Este estande não está mais disponível para novas visitas.',
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ScannerScreen(controller: controller),
                        ),
                      ),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Ler QR Code do estande'),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'O check-in é feito pelo QR Code presente no estande.',
                    style: TextStyle(color: Color(0xFF72806C), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
