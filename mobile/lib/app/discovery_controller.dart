import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/estande.dart';
import '../models/mission.dart';
import '../repositories/estandes_repository.dart';
import '../services/checkin_service.dart';
import '../services/remote_config_service.dart';

class DiscoveryController extends ChangeNotifier {
  DiscoveryController({
    required this.uid,
    required this.repository,
    required this.checkins,
    required this.analytics,
    required this.remote,
  });
  final String uid;
  final EstandesRepository repository;
  final CheckinService checkins;
  final EventAnalytics analytics;
  final RemoteConfigService remote;
  List<Estande> stands = [];
  Set<String> visited = {};
  bool loading = true;
  bool fromCache = false;
  String? standError;
  String? visitError;
  Mission get mission => remote.mission;
  StreamSubscription<StandFeed>? _standsSubscription;
  StreamSubscription<Set<String>>? _visitsSubscription;
  bool _disposed = false;
  void start() {
    remote.addListener(_changed);
    unawaited(remote.start());
    reload();
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  void reload() {
    unawaited(_standsSubscription?.cancel());
    unawaited(_visitsSubscription?.cancel());
    loading = true;
    standError = null;
    visitError = null;
    _changed();
    _standsSubscription = repository.activeStands().listen(
      (feed) {
        stands = feed.stands;
        fromCache = feed.fromCache;
        loading = false;
        standError = null;
        _changed();
      },
      onError: (Object error) {
        loading = false;
        standError = 'Não foi possível carregar os estandes. Verifique a conexão e tente novamente.';
        _changed();
      },
    );
    _visitsSubscription = repository
        .visited(uid)
        .listen(
          (ids) {
            visited = ids;
            visitError = null;
            _changed();
          },
          onError: (Object error) {
            visitError = 'Não foi possível consultar suas visitas. Tente atualizar a lista.';
            _changed();
          },
        );
  }

  Future<Estande> scan(String raw) async {
    final stand = await checkins.scan(raw, uid);
    visited = {...visited, stand.id};
    _changed();
    return stand;
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_standsSubscription?.cancel());
    unawaited(_visitsSubscription?.cancel());
    remote.removeListener(_changed);
    remote.dispose();
    super.dispose();
  }
}
