import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final progress = context.logger.progress('Running post_gen...');

  progress.complete();
  context.logger.success('Done post_gen!');
}
