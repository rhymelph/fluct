import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:io/ansi.dart' as io;
import '../constant.dart';

class CreateCommand extends Command<int> {
  final allowedHelp = {
    'stful': 'Create a new file about StatefulWidget',
    'stless': 'Create a new file about StatelessWidget',
    'custom': "Create a new file about custom widget in 'fluct.yaml'",
  };

  @override
  String get description => 'Help Flutter application create a new file';

  @override
  String get invocation => '${super.invocation} <path>';

  @override
  String get name => 'create';

  CreateCommand() {
    argParser.addOption('type',
        abbr: 't',
        allowed: [
          'stful',
          'stless',
          'custom',
        ],
        allowedHelp: allowedHelp);
    argParser.addOption('arg',
        abbr: 'a',
        help:
            "create a new file about your custom widget use arg in 'fluct.yaml'");
  }
  Logger logger = Logger.standard();

  Future<int> run() async {
    if (argResults.arguments.isEmpty) {
      print(usage);
      logger.stdout(usage);
    } else {
      final type = argResults['type'];
      final path = argResults.arguments.last;
      if (allowedHelp.containsKey(type)) {
        logger.stdout('tip: ${allowedHelp[type]}');
        switch (type) {
          case 'stful':
            createFile(path, stful);
            break;
          case 'stless':
            createFile(path, stful);
            break;
          case 'custom':
            createCustomFile(path);
            break;
        }
      } else {
        logger.stdout(usage);
      }
    }
    return 0;
  }

  void createCustomFile(String path) {
    String arg = argResults['arg'];

    if (arg.isEmpty) {
      logger.stdout(io
          .wrapWith("error:please enter your arg in 'fluct.yaml' ", [io.red]));
      logger.stdout('All done exit 0');
      exit(64);
    }
    final fluctFile = File('fluct.yaml');
    if (!fluctFile.existsSync()) {
      logger.stdout(
          io.wrapWith("error:please create your 'fluct.yaml' ", [io.red]));
      logger.stdout('All done exit 0');
      exit(64);
    }
    final yamlContent = yaml.loadYaml(fluctFile.readAsStringSync());
    final content = yamlContent[arg];
    if (content == null) {
      logger.stdout(io
          .wrapWith("error:not found '$arg' in your 'fluct.yaml' ", [io.red]));
      logger.stdout('All done exit 0');
      exit(64);
    } else {
      createFile(path, content.toString());
    }
  }

  void createFile(String path, String model) {
    var className = '';
    String name;

    if (path.contains('/')) {
      name = path.substring(path.lastIndexOf('/') + 1);
    } else {
      name = path;
    }
    final works = name.split('_');
    for (final work in works) {
      if (work.isNotEmpty) {
        className +=
            work[0].toUpperCase() + (work.length > 1 ? work.substring(1) : '');
      }
    }
    logger.stdout('tip: will create $className class');
    if (className.isEmpty) {
      logger.stdout(io.wrapWith('error:please enter your path', [io.red]));
      logger.stdout('All done exit 0');
      exit(64);
    }
    final file = File('$path.dart');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(model.replaceAll(r'$NAME$', className));
    logger.stdout(io.wrapWith('success: create complete.', [io.green]));
    logger.stdout('All done exit 0');
  }
}
