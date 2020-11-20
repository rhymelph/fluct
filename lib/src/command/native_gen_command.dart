import 'dart:mirrors';

import 'package:args/command_runner.dart';

/// 自动生成对应的native部分代码
class NativeGenCommand extends Command<int> {
  NativeGenCommand() {
    argParser.addOption('input', help: 'you want to generate file path.');
    argParser.addOption('output',
        help: 'you want to generate success file path(.dart)');

    argParser.addOption('ios',
        abbr: 'i',
        allowed: [
          'objc',
          'swift',
        ],
        help: 'ios develop language `objc` or `swift` --default `objc`');

    argParser.addOption('android',
        abbr: 'a',
        allowed: [
          'java',
          'kotlin',
        ],
        help: 'android develop language `java` or `kotlin` --default `java`');
  }

  @override
  String get description => 'Generate Navite Entity,support android and ios';

  @override
  String get name => 'native-gen';

  Future<int> run() async {
    final options = getOptions();
    for (LibraryMirror libraryMirror
        in currentMirrorSystem().libraries.values) {
      for (DeclarationMirror declarationMirror
          in libraryMirror.declarations.values) {
        if (declarationMirror is MethodMirror &&
            MirrorSystem.getName(declarationMirror.simpleName) ==
                'configurePigeon') {
        }
      }
    }
    return 0;
  }

  NativeOptions getOptions() {
    return NativeOptions(
      android: argResults['android'] ?? 'java',
      ios: argResults['ios'] ?? 'kotlin',
      input: argResults['input'],
      output: argResults['output'],
    );
  }

}

class NativeOptions {
  final String android;
  final String ios;
  final String input;
  final String output;

  NativeOptions({this.android, this.ios, this.input, this.output});
}
