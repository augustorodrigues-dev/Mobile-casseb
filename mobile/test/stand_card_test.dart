import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:circuito_descobertas/widgets/stand_card.dart';

import 'core_cases.dart';

void main() {
  testWidgets('Cartão mostra localização, visita e abre detalhes', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StandCard(
            stand: robot,
            visited: true,
            highlighted: false,
            onTap: () {
              taps++;
            },
          ),
        ),
      ),
    );
    expect(find.text('Robótica'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);
    expect(find.text('Visitado'), findsOneWidget);
    expect(find.text('Na missão'), findsNothing);
    await tester.tap(find.text('Robótica'));
    expect(taps, 1);
  });
  testWidgets('Missão ativa destaca o cartão ainda não visitado', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StandCard(
            stand: robot,
            visited: false,
            highlighted: true,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('Na missão'), findsOneWidget);
    expect(find.text('Visitado'), findsNothing);
  });
}
