import 'package:mason/mason.dart';

void run(HookContext context) {
  final progress = context.logger.progress('Running post_gen');

  progress.complete();
  context.logger.success('Done post_gen!');
}
