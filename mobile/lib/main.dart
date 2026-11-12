import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/bootstrap.dart';
import 'app/discovery_controller.dart';
import 'app/theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CircuitoApp());
}

class CircuitoApp extends StatelessWidget {
  const CircuitoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Circuito de Descobertas',
    debugShowCheckedModeBanner: false,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: circuitoTheme(),
    home: const StartupScreen(),
  );
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});
  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  DiscoveryController? _controller;
  String? _error;
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _error = null);
    try {
      final controller = await bootstrap();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (error) {
      debugPrint('Inicialização indisponível: ${error.runtimeType}');
      if (mounted) {
        setState(
          () => _error =
              'Não foi possível conectar ao circuito. Confira sua internet e tente novamente. '
              'Na primeira execução, a organização precisa configurar o Firebase e habilitar a autenticação anônima.',
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller case final controller?) {
      return HomeScreen(controller: controller);
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore_outlined, size: 74, color: forest),
                const SizedBox(height: 24),
                Text(
                  'Circuito de\nDescobertas',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                if (_error == null) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 18),
                  const Text('Preparando sua próxima descoberta…'),
                ] else ...[
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _start,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
