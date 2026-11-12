import 'dart:convert';

import '../core/qr_code.dart';
import 'estande.dart';

class Mission {
  const Mission({this.active = false, this.standIds = const {}});
  final bool active;
  final Set<String> standIds;

  factory Mission.fromRemote({required bool active, required String json}) {
    try {
      final value = jsonDecode(json);
      if (value is! List ||
          value.length > 200 ||
          value.any((id) => id is! String || !validStandId(id))) {
        return Mission(active: active);
      }
      return Mission(
        active: active,
        standIds: Set.unmodifiable(value.cast<String>()),
      );
    } on FormatException {
      return Mission(active: active);
    }
  }
  bool highlights(String id) => active && standIds.contains(id);
  List<Estande> participants(Iterable<Estande> stands) => active
      ? stands
            .where((stand) => stand.ativo && standIds.contains(stand.id))
            .toList()
      : [];
}
