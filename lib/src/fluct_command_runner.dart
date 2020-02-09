

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:fluct/src/utils.dart';
import 'command/create_command.dart';

const packageVersion = '1.0.0';

Future<int> run(List<String> args) => _CommandRunner().run(args);

class _CommandRunner extends CommandRunner<int>{

  _CommandRunner() : super(appName, 'Help to develop Flutter projects.'){
    argParser.addFlag('version',abbr:'v',negatable: false, help: 'Prints the version of fluct');
    addCommand(CreateCommand());
  }
  
  @override
  Future<int> runCommand(ArgResults topLevelResults)async{
    if (topLevelResults['version'] as bool) {
      print(packageVersion);
      return 0;
    }

    return await super.runCommand(topLevelResults) ?? 0;
  }
}