import 'package:flutter/material.dart';

import '../app/bootstrap.dart';
import '../app/discovery_controller.dart';
import '../app/theme.dart';
import '../widgets/stand_card.dart';
import 'mission_screen.dart';
import 'scanner_screen.dart';
import 'stand_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});
  final DiscoveryController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final mission = controller.mission;
      return Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.explore_outlined, size: 30),
              SizedBox(width: 10),
              Text(
                'Circuito de Descobertas',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Atualizar lista',
              onPressed: controller.reload,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: forest,
          foregroundColor: Colors.white,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ScannerScreen(controller: controller),
            ),
          ),
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Escanear QR Code'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 110),
                children: [
                  const Text(
                    'AMAZON HACKING · CESUPA',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF788C68),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Siga a curiosidade.\nEncontre o extraordinário.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Explore projetos, conheça ideias e registre cada descoberta.',
                    style: TextStyle(color: Color(0xFF72806C)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0DF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.route, color: forest),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${controller.visited.length} descoberta(s) registrada(s)',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (useEmulators)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Ambiente local · Remote Config e Analytics exigem o projeto Firebase real.',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  if (controller.fromCache)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Exibindo dados locais enquanto aguardamos o servidor. Check-ins exigem conexão.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A6222),
                        ),
                      ),
                    ),
                  if (controller.remote.warning case final warning?)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        warning,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  if (controller.visitError case final error?)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.brown),
                      ),
                    ),
                  if (mission.active) ...[
                    const SizedBox(height: 22),
                    _MissionBanner(
                      onOpen: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MissionScreen(controller: controller),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Text(
                        'Explore os estandes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      Text(
                        '${controller.stands.length} ativos',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF72806C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (controller.loading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (controller.standError case final error?)
                    Column(
                      children: [
                        Text(error),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: controller.reload,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    )
                  else if (controller.stands.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'O circuito está sendo preparado. Os estandes aparecerão aqui quando a organização ativá-los.',
                      ),
                    )
                  else
                    ...controller.stands.map(
                      (stand) => StandCard(
                        stand: stand,
                        visited: controller.visited.contains(stand.id),
                        highlighted: mission.highlights(stand.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StandScreen(
                              stand: stand,
                              controller: controller,
                            ),
                          ),
                        ),
                      ),
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

class _MissionBanner extends StatelessWidget {
  const _MissionBanner({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: forest,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: lime),
            SizedBox(width: 8),
            Text(
              'MISSÃO SURPRESA',
              style: TextStyle(
                color: lime,
                letterSpacing: 1.5,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Novos caminhos.\nGrandes descobertas.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Uma seleção especial de projetos espera por você.',
          style: TextStyle(color: Color(0xFFBED4BC)),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onOpen,
          style: FilledButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: forest,
          ),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Abrir missão'),
        ),
      ],
    ),
  );
}
