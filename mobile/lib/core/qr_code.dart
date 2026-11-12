final _standId = RegExp(r'^[A-Za-z0-9-]{1,128}$');
bool validStandId(String value) => _standId.hasMatch(value);

/// Formato canônico compartilhado com o gerador do painel.
/// Rejeita links de terceiros, escapes, parâmetros e caminhos adicionais.
String parseStandQr(String raw) {
  if (raw.length > 160 || !raw.startsWith('circuito://estande/')) {
    throw const FormatException(
      'Este QR Code não pertence ao Circuito de Descobertas.',
    );
  }
  final id = raw.substring('circuito://estande/'.length);
  if (!validStandId(id)) {
    throw const FormatException(
      'QR Code inválido. Use o código exibido no estande.',
    );
  }
  return id;
}
