import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:fluct/src/command/strings_translate_command.dart';
import 'package:fluct/src/utils.dart';
import 'command/assets_gen_command.dart';
import 'command/create_command.dart';
import 'command/native_gen_command.dart';
import 'command/strings_gen_command.dart';
import 'command/strings_replace_command.dart';

const packageVersion = '1.0.8';

Future<int> run(List<String> args) => _CommandRunner().run(args);

class _CommandRunner extends CommandRunner<int> {
  _CommandRunner() : super(appName, 'Help to develop Flutter projects.') {
    argParser.addFlag('version',
        abbr: 'v', negatable: false, help: 'Prints the version of fluct');
    addCommand(CreateCommand());
    addCommand(AssetsGenCommand());
    addCommand(StringsGenCommand());
    addCommand(StringsReplaceCommand());
    addCommand(StringsTranslateCommand());
    addCommand(NativeGenCommand());
  }

  @override
  Future<int> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] as bool) {
      print('version ==> v$packageVersion');
      print('pub     ==> https://pub.dev/packages/fluct');
      print('author  ==> rhymelph');
      print('github  ==> https://github.com/rhymelph');
      print('email   ==> rhymelph@gmail.com');
      return 0;
    }

    return await super.runCommand(topLevelResults) ?? 0;
  }
}
