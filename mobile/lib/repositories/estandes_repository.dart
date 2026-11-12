import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/visit_failure.dart';
import '../models/estande.dart';
import '../services/checkin_service.dart';

class StandFeed {
  const StandFeed(this.stands, this.fromCache);
  final List<Estande> stands;
  final bool fromCache;
}

class EstandesRepository implements CheckinStore {
  EstandesRepository(this.db);
  final FirebaseFirestore db;
  Stream<StandFeed> activeStands() => db
      .collection('estandes')
      .where('ativo', isEqualTo: true)
      .snapshots(includeMetadataChanges: true)
      .map((snapshot) {
        final stands =
            snapshot.docs
                .map((doc) => Estande.fromMap(doc.id, doc.data()))
                .toList()
              ..sort((a, b) => a.nome.compareTo(b.nome));
        return StandFeed(stands, snapshot.metadata.isFromCache);
      });
  Stream<Set<String>> visited(String uid) => db
      .collection('checkins')
      .where('visitanteId', isEqualTo: uid)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => doc.data()['estandeId'] as String)
            .toSet(),
      );
  @override
  Future<Estande> createOnce(String visitorId, String standId) async {
    final standRef = db.collection('estandes').doc(standId);
    final checkinRef = db.collection('checkins').doc('${visitorId}_$standId');
    try {
      return await db.runTransaction<Estande>(
        (transaction) async {
          final standDoc = await transaction.get(standRef);
          if (!standDoc.exists) {
            throw const VisitFailure(VisitFailureCode.notFound);
          }
          final stand = Estande.fromMap(standDoc.id, standDoc.data()!);
          if (!stand.ativo) throw const VisitFailure(VisitFailureCode.inactive);
          final existing = await transaction.get(checkinRef);
          if (existing.exists) {
            throw const VisitFailure(VisitFailureCode.duplicate);
          }
          // Set após leitura inexistente gera precondição transacional.
          // As regras permitem create e negam update, mesmo com cliente adulterado.
          transaction.set(checkinRef, {
            'visitanteId': visitorId,
            'estandeId': standId,
            'criadoEm': FieldValue.serverTimestamp(),
          });
          return stand;
        },
        timeout: const Duration(seconds: 15),
        maxAttempts: 3,
      );
    } on FirebaseException catch (error) {
      throw VisitFailure(switch (error.code) {
        'unavailable' || 'deadline-exceeded' => VisitFailureCode.offline,
        'permission-denied' => VisitFailureCode.denied,
        'already-exists' => VisitFailureCode.duplicate,
        'unauthenticated' => VisitFailureCode.unauthenticated,
        _ => VisitFailureCode.writeFailed,
      });
    }
  }
}
