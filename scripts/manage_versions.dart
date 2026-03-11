import 'dart:io';

void main(List<String> args) {
  final bricksDir = Directory('bricks');
  if (!bricksDir.existsSync()) {
    print('Error: bricks directory not found.');
    exit(1);
  }

  final standardVersion = args.isNotEmpty ? args[0] : '^0.1.1';
  print('Standardizing Mason version to: $standardVersion');

  final bricks = bricksDir.listSync().whereType<Directory>();

  for (final brick in bricks) {
    final brickYaml = File('${brick.path}/brick.yaml');
    if (brickYaml.existsSync()) {
      _updateBrickYaml(brickYaml, standardVersion);
    }
  }
}

void _updateBrickYaml(File file, String version) {
  final lines = file.readAsLinesSync();
  final updatedLines = <String>[];
  bool updated = false;
  bool inEnvironment = false;

  for (var line in lines) {
    if (line.trim().startsWith('environment:')) {
      inEnvironment = true;
      updatedLines.add(line);
      continue;
    }

    if (inEnvironment && line.trim().startsWith('mason:')) {
      final leadingWhitespace = line.substring(0, line.indexOf('mason:'));
      updatedLines.add('$leadingWhitespace\mason: $version');
      updated = true;
      inEnvironment = false;
      continue;
    }

    if (inEnvironment && line.trim().isEmpty) {
      // If we hit an empty line after environment but before mason, something is weird, 
      // but we'll just keep going.
    } else if (inEnvironment && !line.startsWith(' ') && !line.startsWith('\t')) {
       inEnvironment = false;
    }

    updatedLines.add(line);
  }

  if (updated) {
    file.writeAsStringSync(updatedLines.join('\n') + '\n');
    print('Updated ${file.path}');
  } else {
    print('Could not find mason environment constraint in ${file.path}');
  }
}
