import 'dart:io';
import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:fluct/src/utils.dart';
import 'package:io/ansi.dart' as io;

const _outputName = 'strings.json';

/// 自动将项目中包含中文的字符串进行采集
class StringsGenCommand extends Command<int> {
  StringsGenCommand() {
    argParser.addOption('output',
        abbr: 'o',
        help: 'Your output directory path -- default `./lib/generated`.');
    argParser.addOption('assets',
        abbr: 'a', help: 'Your asset directory path -- default `./lib`.');
    argParser.addFlag('translate',
        abbr: 't', help: 'Auto translate Chinese to English.');
  }
  @override
  String get description => 'Auto generate chinese strings to json file.';

  @override
  String get name => 'strings-gen';

  Logger logger = Logger.standard();

  Future<int> run() async {
    String outputPath = './lib/generated';
    String libPath = './lib';
    bool isTranslate = argResults['translate'];

    if (argResults['output'] != null) {
      outputPath = argResults['output'];
    }
    if (argResults['assets'] != null) {
      libPath = argResults['assets'];
    }
    logger.stdout('tip: assets directory path in `${libPath}`');
    logger.stdout('tip: output directory path in `${outputPath}`');

    Directory libDirectory = Directory(libPath);
    if (!await libDirectory.exists()) {
      logger.stdout(
          io.wrapWith('error: assets file path is not exists.', [io.red]));
      print('exit 0');
      return 0;
    }
    final progress =
        logger.progress('waiting: seek chinese strings form your $libPath');
    File stringFile = File('$outputPath/$_outputName');
    if (stringFile.existsSync()) {
      await stringFile.delete();
    }
    await stringFile.create(recursive: true);
    final sink = stringFile.openWrite(mode: FileMode.append);
    List<String> strings = [];
    await readDirectory(libDirectory, strings);
    int index = 0;

    Map<String, String> resultMap = {};
    for (int i = 0; i < strings.length; i++) {
      String string = strings[i];
      // if(string.contains('\$')){
      //   final _scanner=StringScanner(string);
      //  int position = _scanner.position;
      //   while(!_scanner.isDone){
      //     _scanner.scan(RegExp(r'\s+'));
      //     if (_scanner.scan(RegExp(r'\${.*}')) ||
      //         _scanner.scan(RegExp(r"\$.* "))) {
      //       // collectionString(_scanner.lastMatch.start + ignoreIndex,
      //       //     _scanner.lastMatch.end - ignoreIndex);
      //       continue;
      //     }
      //     if (_scanner.position == string.length) {
      //       break;
      //     }
      //     if (position == _scanner.position) {
      //       _scanner.position = position + 1;
      //     }
      //     position = _scanner.position;
      //   }
      // }
      if (!resultMap.containsValue(string)) {
        if (isTranslate) {
          try {
            final english = await transform(string);
            resultMap['${english.replaceAll(' ', '_')}'] = strings[i];
          } catch (e) {
            resultMap['$index'] = strings[i];
          }
        } else {
          resultMap['$index'] = strings[i];
        }
        index++;
      }
    }
    sink.write(json.encode(resultMap));
    await sink.close();
    progress.finish(showTiming: true);
    logger.stdout(io.wrapWith(
        'success: generate complete,new file in `${stringFile.path}`',
        [io.green]));
    logger.stdout('All done exit 0');
    return 0;
  }

  Future<void> readDirectory(Directory directory, List<String> strings) async {
    final libList = directory.listSync();
    for (final file in libList) {
      // print('scan:${file.path}');
      if (await FileSystemEntity.isDirectory(file.path)) {
        // assetDirectories.add(file.path);
        await readDirectory(Directory(file.path), strings);
      } else {
        final mFile = File(file.path);
        final sourceContent = await mFile.readAsString();

        void collectionString(
          int start,
          int end,
        ) {
          final resultContent = sourceContent.substring(start, end);
          if (hasChinese(resultContent)) {
            // String transformResult = await transform(con);
            // print(con);
            // print(resultContent);
            strings.add(resultContent);
          }
        }

        final entities = getStringFromFile(sourceContent);
        for (final entity in entities) {
          collectionString(
              entity.start + entity.ignoreNumber + (entity.isPrefixR ? 1 : 0),
              entity.end - entity.ignoreNumber);
        }
      }
    }
  }
}
