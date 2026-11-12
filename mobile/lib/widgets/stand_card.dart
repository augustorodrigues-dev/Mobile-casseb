import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/estande.dart';

class StandCard extends StatelessWidget {
  const StandCard({
    super.key,
    required this.stand,
    required this.visited,
    required this.highlighted,
    required this.onTap,
  });
  final Estande stand;
  final bool visited;
  final bool highlighted;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: highlighted ? const Color(0xFF9CBA59) : const Color(0xFFE5EADB),
        width: highlighted ? 2 : 1,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: highlighted ? lime : const Color(0xFFEDF2E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    highlighted ? Icons.auto_awesome : Icons.hub_outlined,
                    color: forest,
                    size: 23,
                  ),
                ),
                const Spacer(),
                if (visited)
                  const Chip(
                    avatar: Icon(Icons.check_circle, size: 17, color: forest),
                    label: Text('Visitado'),
                    visualDensity: VisualDensity.compact,
                  ),
                if (!visited && highlighted)
                  const Chip(
                    label: Text('Na missão'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(stand.nome, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              stand.descricao,
              style: const TextStyle(color: Color(0xFF72806C)),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 17, color: forest),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    stand.localizacao,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 19,
                  color: forest,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
