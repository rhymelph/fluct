import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:fluct/src/entity/string_entity.dart';
import 'package:fluct/src/utils.dart';
import 'package:string_scanner/string_scanner.dart';

/// 自动翻译对应的json文件中的值
class StringsTranslateCommand extends Command<int> {
  StringsTranslateCommand() {
    argParser.addOption('input',
        abbr: 'i',
        help:
        'you want to translate file (only support .json).');
  }
  @override
  String get description => 'Auto translate string to your input.';

  @override
  String get name => 'strings-translate';

  Logger logger = Logger.standard();


  Future<int> run() async {
    String input;
    if (argResults['input'] != null) {
      input = argResults['input'];
    }else{
      logger.stdout('please input your file path');
      logger.stdout('All finish exit 0');
    }
    final inputFile = File(input);

    final progress = logger.progress('wating: replace string running....');

    final jsonString = await inputFile.readAsString();
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    var resultMap = <String,dynamic>{};
    for(final jsonItem in jsonMap.entries){
        resultMap[jsonItem.key] = await transform(jsonItem.value);
    }
    await inputFile.writeAsString(json.encode(resultMap));
    progress.finish(showTiming: true);
    logger.stdout('All finish exit 0');
    return 0;
  }
}
