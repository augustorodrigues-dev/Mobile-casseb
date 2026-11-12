enum VisitFailureCode {
  notFound,
  inactive,
  duplicate,
  offline,
  denied,
  unauthenticated,
  busy,
  writeFailed,
}

class VisitFailure implements Exception {
  const VisitFailure(this.code);
  final VisitFailureCode code;
  String get message => switch (code) {
    VisitFailureCode.notFound =>
      'Estande não encontrado. Confira o QR Code com a organização.',
    VisitFailureCode.inactive =>
      'Este estande está inativo e não aceita novos check-ins.',
    VisitFailureCode.duplicate =>
      'Você já descobriu este estande! Sua visita já está registrada.',
    VisitFailureCode.offline =>
      'Sem conexão com o Firebase. Conecte-se à internet e tente novamente.',
    VisitFailureCode.denied => 'Não foi possível autorizar o check-in. Confirme com a organização se o estande continua ativo.',
    VisitFailureCode.unauthenticated =>
      'Sua sessão expirou. Volte ao início e tente novamente.',
    VisitFailureCode.busy => 'Um QR Code já está sendo processado. Aguarde.',
    VisitFailureCode.writeFailed => 'Não foi possível gravar a visita. Tente novamente. Se ela já tiver sido salva, a próxima leitura confirmará o registro.',
  };
  @override
  String toString() => message;
}
