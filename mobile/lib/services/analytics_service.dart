import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'checkin_service.dart';

class AnalyticsService implements EventAnalytics {
  AnalyticsService(this._analytics);
  final FirebaseAnalytics? _analytics;
  Future<void> _send(String name, [Map<String, Object>? parameters]) async {
    final analytics = _analytics;
    if (analytics == null) return;
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (error) {
      // Uma indisponibilidade de telemetria não desfaz uma visita confirmada.
      debugPrint('Analytics indisponível: ${error.runtimeType}');
    }
  }

  @override
  Future<void> missionOpened() => _send('missao_aberta');
  @override
  Future<void> checkinCompleted(String standId) =>
      _send('checkin_concluido', {'estande_id': standId});
}
