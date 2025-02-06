import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final progress = context.logger.progress('Installing Packages');

  await Process.run(
    'flutter',
    ['pub', 'add', 'dart_pusher_channels'],
    runInShell: true,
  );

  await Process.run(
    'flutter',
    ['pub', 'get'],
    runInShell: true,
  );

  progress.complete();
  context.logger.success('Done installing packages!');
}
