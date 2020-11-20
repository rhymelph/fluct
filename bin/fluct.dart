import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fluct/src/fluct_command_runner.dart';
import 'package:io/ansi.dart';
import 'package:io/io.dart';

void main(List<String> arguments) async {
  try {
    exitCode = await run(arguments);
  } catch (e, s) {
    if (e is UsageException) {
      print(red.wrap(e.message));
      print(' ');
      print(e.usage);
      exitCode = ExitCode.usage.code;
    } else {
      print(red.wrap(e.toString()));
      print(red.wrap(s.toString()));
      exitCode = ExitCode.unavailable.code;
    }
  }
}
