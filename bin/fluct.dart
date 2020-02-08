import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fluct/fluct.dart' as fluct;

void main(List<String> arguments) {
  var run = CommandRunner('fluct', 'create your flutter path')
  ..addCommand(fluct.CreateCommand())
  ..run(arguments).catchError((error){
    if(error is UsageException) throw error;
    print(error);
    exit(64);
  });
}
