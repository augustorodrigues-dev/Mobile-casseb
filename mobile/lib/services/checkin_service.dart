import '../core/qr_code.dart';
import '../core/visit_failure.dart';
import '../models/estande.dart';

abstract interface class CheckinStore {
  /// Retorna somente após confirmação do commit pelo servidor.
  Future<Estande> createOnce(String visitorId, String standId);
}

abstract interface class EventAnalytics {
  Future<void> missionOpened();
  Future<void> checkinCompleted(String standId);
}

class CheckinService {
  CheckinService(this.store, this.analytics);
  final CheckinStore store;
  final EventAnalytics analytics;
  bool _processing = false;

  Future<Estande> scan(String raw, String visitorId) async {
    if (_processing) throw const VisitFailure(VisitFailureCode.busy);
    final id = parseStandQr(raw);
    if (visitorId.isEmpty) {
      throw const VisitFailure(VisitFailureCode.unauthenticated);
    }
    _processing = true;
    try {
      final stand = await store.createOnce(visitorId, id);
      // Nunca dentro da transação: o SDK pode repetir o callback em conflitos.
      await analytics.checkinCompleted(id);
      return stand;
    } finally {
      _processing = false;
    }
  }
}
