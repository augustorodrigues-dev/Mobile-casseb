import 'package:flutter_test/flutter_test.dart';

import 'core_cases.dart';

void main() {
  for (final (name, body) in coreCases()) {
    test(name, body);
  }
}
