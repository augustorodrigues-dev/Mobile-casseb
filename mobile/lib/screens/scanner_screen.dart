import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app/discovery_controller.dart';
import '../app/theme.dart';
import '../core/visit_failure.dart';
import '../models/estande.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, required this.controller});
  final DiscoveryController controller;
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final _camera = MobileScannerController(
    autoStart: false,
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _permission = false;
  bool _requesting = false;
  bool _busy = false;
  bool _starting = false;
  bool _checkingPermission = true;
  String? _cameraError;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkPermission(request: true));
  }

  Future<void> _checkPermission({bool request = false}) async {
    if (_requesting) return;
    _requesting = true;
    try {
      final status = request
          ? await Permission.camera.request()
          : await Permission.camera.status;
      if (!mounted) return;
      setState(() {
        _permission = status.isGranted;
        _checkingPermission = false;
        _cameraError = null;
      });
      if (status.isGranted) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => unawaited(_start()),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _checkingPermission = false;
          _cameraError = 'Não foi possível solicitar acesso à câmera.';
        });
      }
    } finally {
      _requesting = false;
    }
  }

  Future<void> _start() async {
    if (!mounted ||
        !_permission ||
        _busy ||
        _starting ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    _starting = true;
    try {
      await _camera.start();
    } catch (_) {
      if (mounted) {
        setState(
          () => _cameraError = 'Não foi possível iniciar a câmera. Verifique a configuração da câmera do AVD ou tente novamente.',
        );
      }
    } finally {
      _starting = false;
    }
  }

  Future<void> _stop() async {
    try {
      await _camera.stop();
    } catch (_) {
      /* A câmera pode já ter sido suspensa pelo Android. */
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkPermission());
    } else {
      unawaited(_stop());
    }
  }

  Future<void> _detect(BarcodeCapture capture) async {
    if (_busy) return;
    final raw = capture.barcodes
        .where((b) => b.rawValue != null)
        .firstOrNull
        ?.rawValue;
    if (raw == null) return;
    setState(() => _busy = true);
    await _stop();
    try {
      final stand = await widget.controller.scan(raw);
      if (!mounted) return;
      unawaited(
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => _CheckinSuccess(stand: stand),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final duplicate =
          error is VisitFailure && error.code == VisitFailureCode.duplicate;
      final message = error is FormatException
          ? error.message
          : error is VisitFailure
          ? error.message
          : const VisitFailure(VisitFailureCode.writeFailed).message;
      final retry = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: Icon(
            duplicate ? Icons.check_circle_outline : Icons.info_outline,
            color: forest,
          ),
          title: Text(
            duplicate ? 'Visita já registrada' : 'Confira sua leitura',
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Voltar ao circuito'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ler outro QR Code'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (retry == true) {
        setState(() => _busy = false);
        await _start();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_camera.dispose());
    super.dispose();
  }

  Widget _cameraProblem(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.no_photography_outlined, size: 54, color: forest),
          const SizedBox(height: 20),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => unawaited(_checkPermission(request: true)),
            child: const Text('Tentar novamente'),
          ),
          TextButton(
            onPressed: () async {
              await openAppSettings();
            },
            child: const Text('Abrir configurações de permissão'),
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Registrar descoberta')),
    body: SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Text(
              'Aponte a câmera para o QR Code do estande. O registro exige conexão com a internet.',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _checkingPermission
                ? const Center(child: CircularProgressIndicator())
                : !_permission
                ? _cameraProblem(
                    'Permita o acesso à câmera para ler o QR Code. Se a permissão estiver bloqueada, habilite-a nas configurações do Android.',
                  )
                : _cameraError != null
                ? _cameraProblem(_cameraError!)
                : ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        MobileScanner(
                          controller: _camera,
                          useAppLifecycleState: false,
                          onDetect: (capture) => unawaited(_detect(capture)),
                          errorBuilder: (_, error) => _cameraProblem(
                            error.errorCode ==
                                    MobileScannerErrorCode.permissionDenied
                                ? 'O acesso à câmera foi negado.'
                                : 'Câmera indisponível. Verifique a câmera traseira do emulador.',
                          ),
                        ),
                        IgnorePointer(
                          child: Center(
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                border: Border.all(color: lime, width: 3),
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                        if (_busy)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: lime),
                                  SizedBox(height: 18),
                                  Text(
                                    'Validando e registrando sua visita…',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

class _CheckinSuccess extends StatelessWidget {
  const _CheckinSuccess({required this.stand});
  final Estande stand;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: lime,
                ),
                child: const Icon(Icons.check_rounded, size: 70, color: forest),
              ),
              const SizedBox(height: 32),
              Text(
                'Descoberta registrada!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 18),
              Text(
                stand.nome,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Seu check-in foi salvo. Continue explorando e conhecendo os projetos do evento.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Continuar descobrindo'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
