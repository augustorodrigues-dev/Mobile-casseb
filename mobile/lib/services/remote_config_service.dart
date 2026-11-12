import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../models/mission.dart';

class RemoteConfigService extends ChangeNotifier {
  RemoteConfigService(this.remoteConfig);
  final FirebaseRemoteConfig? remoteConfig;
  Mission mission = const Mission();
  String? warning;
  StreamSubscription<RemoteConfigUpdate>? _subscription;
  bool _disposed = false;
  Future<void> start() async {
    final config = remoteConfig;
    if (config == null) return; // Remote Config não possui emulador local.
    try {
      await config.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await config.setDefaults({
        'missao_ativa': false,
        'estandes_destaque': '[]',
      });
      await config.ensureInitialized();
      _apply(); // Valores já ativados no cache, mesmo offline.
      if (_disposed) return;
      _subscription = config.onConfigUpdated.listen((update) async {
        try {
          await config.activate();
          _apply();
        } catch (_) {
          _warn();
        }
      }, onError: (Object error) => _warn());
      await config.fetchAndActivate();
      _apply();
    } catch (_) {
      _warn();
    }
  }

  void _apply() {
    final config = remoteConfig;
    if (_disposed || config == null) return;
    mission = Mission.fromRemote(
      active: config.getBool('missao_ativa'),
      json: config.getString('estandes_destaque'),
    );
    warning = null;
    notifyListeners();
  }

  void _warn() {
    if (_disposed) return;
    warning = 'Não foi possível atualizar a missão. A lista e os check-ins continuam disponíveis.';
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
