import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final progress = context.logger.progress('Installing Packages');

  await Process.run('flutter', [
    'pub',
    'add',
    'auto_route',
    'firebase_crashlytics',
    'flutter_secure_storage',
  ], runInShell: true);

  await Process.run('flutter', [
    'pub',
    'add',
    '--dev',
    'build_runner',
    'auto_route_generator',
  ], runInShell: true);

  await Process.run('flutter', ['pub', 'get'], runInShell: true);

  progress.complete();
  context.logger.success('Done instaling packages!');
}
