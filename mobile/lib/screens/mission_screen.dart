import 'dart:async';

import 'package:flutter/material.dart';

import '../app/discovery_controller.dart';
import '../app/theme.dart';
import '../widgets/stand_card.dart';
import 'stand_screen.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key, required this.controller});
  final DiscoveryController controller;
  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  @override
  void initState() {
    super.initState();
    // O evento só é emitido após a navegação e o primeiro frame desta tela.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller.mission.active) {
        unawaited(widget.controller.analytics.missionOpened());
      }
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final participants = controller.mission.participants(controller.stands);
      final completed = participants
          .where((s) => controller.visited.contains(s.id))
          .length;
      return Scaffold(
        appBar: AppBar(title: const Text('Missão surpresa')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  const Icon(Icons.auto_awesome, size: 56, color: forest),
                  const SizedBox(height: 20),
                  Text(
                    controller.mission.active
                        ? 'Vá além do caminho habitual.'
                        : 'Esta missão foi encerrada.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    controller.mission.active
                        ? 'Visite os projetos selecionados e registre suas descobertas pelos QR Codes.'
                        : 'Você pode continuar explorando e registrando visitas em todos os estandes ativos.',
                  ),
                  const SizedBox(height: 22),
                  if (!controller.mission.active)
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Voltar ao circuito'),
                    )
                  else if (controller.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (controller.standError case final error?)
                    Column(
                      children: [
                        Text(error),
                        OutlinedButton(
                          onPressed: controller.reload,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    )
                  else if (participants.isEmpty)
                    const Text(
                      'A organização está preparando os estandes desta missão. Continue explorando o circuito!',
                    )
                  else ...[
                    Text(
                      '$completed de ${participants.length} descobertas nesta missão',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: completed / participants.length,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 24),
                    ...participants.map(
                      (stand) => StandCard(
                        stand: stand,
                        visited: controller.visited.contains(stand.id),
                        highlighted: true,
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
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
