import 'dart:async';

import 'package:circuito_descobertas/core/qr_code.dart';
import 'package:circuito_descobertas/core/visit_failure.dart';
import 'package:circuito_descobertas/models/estande.dart';
import 'package:circuito_descobertas/models/mission.dart';
import 'package:circuito_descobertas/services/checkin_service.dart';

typedef CoreCase = (String, FutureOr<void> Function());
void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> rejects(
  FutureOr<void> Function() action,
  bool Function(Object) matches,
) async {
  try {
    await action();
  } catch (error) {
    check(matches(error), 'Exceção inesperada: $error');
    return;
  }
  throw StateError('A operação deveria ter falhado.');
}

const robot = Estande(
  id: 'robotica',
  nome: 'Robótica',
  descricao: 'Robôs',
  localizacao: 'A1',
  ativo: true,
);
const inactive = Estande(
  id: 'inativo',
  nome: 'Inativo',
  descricao: 'Teste',
  localizacao: 'A2',
  ativo: false,
);

class MemoryStore implements CheckinStore {
  final Set<String> visits = {};
  int calls = 0;
  VisitFailureCode? failure;
  Completer<void>? wait;
  @override
  Future<Estande> createOnce(String visitorId, String standId) async {
    calls++;
    if (wait != null) await wait!.future;
    if (failure != null) throw VisitFailure(failure!);
    if (standId != robot.id) {
      throw const VisitFailure(VisitFailureCode.notFound);
    }
    if (!visits.add('${visitorId}_$standId')) {
      throw const VisitFailure(VisitFailureCode.duplicate);
    }
    return robot;
  }
}

class RecordingAnalytics implements EventAnalytics {
  final List<String> events = [];
  @override
  Future<void> missionOpened() async {
    events.add('missao_aberta');
  }

  @override
  Future<void> checkinCompleted(String standId) async {
    events.add('checkin_concluido:$standId');
  }
}

List<CoreCase> coreCases() => [
  (
    'QR canônico extrai identificador',
    () {
      check(
        parseStandQr('circuito://estande/AbC-123') == 'AbC-123',
        'ID incorreto',
      );
    },
  ),
  for (final value in [
    '',
    'https://exemplo.com',
    'outro://estande/robotica',
    'CIRCUITO://estande/robotica',
  ])
    (
      'QR de outro sistema é rejeitado: $value',
      () => rejects(() {
        parseStandQr(value);
      }, (e) => e is FormatException),
    ),
  for (final id in [
    '',
    '../robotica',
    'x/y',
    'id?x=1',
    'id#x',
    '%72obotica',
    'id_com_underscore',
    'id com espaco',
    'robótica',
    ' id',
    'id\n',
    'a' * 129,
  ])
    (
      'ID inválido é rejeitado: $id',
      () => rejects(() {
        parseStandQr('circuito://estande/$id');
      }, (e) => e is FormatException),
    ),
  (
    'ID de 128 caracteres é aceito',
    () {
      check(validStandId('a' * 128), 'Comprimento limite');
    },
  ),
  (
    'Missão desativada não destaca estandes',
    () {
      final mission = Mission.fromRemote(active: false, json: '["robotica"]');
      check(
        !mission.highlights('robotica') &&
            mission.participants([robot]).isEmpty,
        'Missão desligada',
      );
    },
  ),
  (
    'Missão ativa filtra IDs inexistentes e inativos',
    () {
      final mission = Mission.fromRemote(
        active: true,
        json: '["robotica","inativo","ausente","robotica"]',
      );
      check(mission.standIds.length == 3, 'IDs duplicados');
      check(
        mission.participants([robot, inactive]).single.id == 'robotica',
        'Participantes inválidos',
      );
    },
  ),
  for (final json in ['', '{', '{}', 'null', '[1]', '["../x"]', '"robotica"'])
    (
      'JSON inválido mantém missão utilizável: $json',
      () {
        final mission = Mission.fromRemote(active: true, json: json);
        check(mission.active && mission.standIds.isEmpty, 'Fallback inválido');
      },
    ),
  (
    'Configuração vazia é válida',
    () {
      check(
        Mission.fromRemote(active: true, json: '[]').standIds.isEmpty,
        'Array vazio',
      );
    },
  ),
  (
    'Lista remota excessiva é rejeitada',
    () {
      final json = '[${List.filled(201, '"robotica"').join(',')}]';
      check(
        Mission.fromRemote(active: true, json: json).standIds.isEmpty,
        'Limite de configuração',
      );
    },
  ),
  (
    'Check-in gera evento somente após commit',
    () async {
      final store = MemoryStore()..wait = Completer<void>();
      final analytics = RecordingAnalytics();
      final service = CheckinService(store, analytics);
      final pending = service.scan('circuito://estande/robotica', 'visitor');
      check(analytics.events.isEmpty, 'Evento antes do commit');
      store.wait!.complete();
      check((await pending).id == 'robotica', 'Resultado');
      check(
        analytics.events.single == 'checkin_concluido:robotica',
        'Evento/parâmetro',
      );
    },
  ),
  (
    'Duplicidade não gera outro evento',
    () async {
      final store = MemoryStore();
      final analytics = RecordingAnalytics();
      final service = CheckinService(store, analytics);
      await service.scan('circuito://estande/robotica', 'visitor');
      await rejects(
        () => service.scan('circuito://estande/robotica', 'visitor'),
        (e) => e is VisitFailure && e.code == VisitFailureCode.duplicate,
      );
      check(
        store.visits.length == 1 && analytics.events.length == 1,
        'Visita duplicada',
      );
    },
  ),
  (
    'Leituras simultâneas são bloqueadas e o scanner é liberado',
    () async {
      final store = MemoryStore()..wait = Completer<void>();
      final analytics = RecordingAnalytics();
      final service = CheckinService(store, analytics);
      final first = service.scan('circuito://estande/robotica', 'visitor');
      await rejects(
        () => service.scan('circuito://estande/robotica', 'visitor'),
        (e) => e is VisitFailure && e.code == VisitFailureCode.busy,
      );
      store.wait!.complete();
      await first;
      await service.scan('circuito://estande/robotica', 'outro');
      check(
        store.calls == 2 && store.visits.length == 2,
        'Bloqueio não foi liberado',
      );
    },
  ),
  for (final failure in [
    VisitFailureCode.inactive,
    VisitFailureCode.offline,
    VisitFailureCode.denied,
    VisitFailureCode.notFound,
    VisitFailureCode.writeFailed,
  ])
    (
      'Falha $failure não envia Analytics e permite nova leitura',
      () async {
        final store = MemoryStore()..failure = failure;
        final analytics = RecordingAnalytics();
        final service = CheckinService(store, analytics);
        await rejects(
          () => service.scan('circuito://estande/robotica', 'visitor'),
          (e) => e is VisitFailure && e.code == failure,
        );
        check(analytics.events.isEmpty, 'Evento em falha');
        store.failure = null;
        await service.scan('circuito://estande/robotica', 'visitor');
        check(analytics.events.length == 1, 'Scanner permaneceu bloqueado');
      },
    ),
  (
    'QR inválido e sessão vazia não consultam o banco',
    () async {
      final store = MemoryStore();
      final analytics = RecordingAnalytics();
      final service = CheckinService(store, analytics);
      await rejects(
        () => service.scan('invalido', 'visitor'),
        (e) => e is FormatException,
      );
      await rejects(
        () => service.scan('circuito://estande/robotica', ''),
        (e) => e is VisitFailure && e.code == VisitFailureCode.unauthenticated,
      );
      check(
        store.calls == 0 && analytics.events.isEmpty,
        'Acesso indevido ao banco',
      );
    },
  ),
];
