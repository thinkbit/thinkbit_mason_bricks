import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) async {
  final progress = context.logger.progress('Installing Packages');

  await Process.run(
    'flutter',
    ['pub', 'add', 'auto_route'],
    runInShell: true,
  );

  await Process.run(
    'flutter',
    ['pub', 'get'],
    runInShell: true,
  );

  progress.complete();
  context.logger.success('Done instaling packages!');
}
