// Executa os MESMOS casos puros da suíte Flutter sem baixar pacotes.
import 'dart:io';

import '../test/core_cases.dart';

Future<void> main() async {
  var passed = 0;
  var failed = 0;
  for (final (name, body) in coreCases()) {
    try {
      await body();
      passed++;
      stdout.writeln('PASS $name');
    } catch (error, stack) {
      failed++;
      stderr.writeln('FAIL $name\n$error\n$stack');
    }
  }
  stdout.writeln('$passed aprovados; $failed falharam.');
  if (failed > 0) exitCode = 1;
}
