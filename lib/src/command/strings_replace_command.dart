import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:fluct/src/entity/string_entity.dart';
import 'package:fluct/src/utils.dart';
import 'package:string_scanner/string_scanner.dart';

/// 自动将特定的json文件查找value，并替换为${source}.key
class StringsReplaceCommand extends Command<int> {
  StringsReplaceCommand() {
    argParser.addOption('import',
        abbr: 'i',
        help:
            'you want to import package --default `import package:../generated/i18n.dart;`.');
    argParser.addOption('var',
        abbr: 'v', help: 'your value --default `S.of(context)`.');
    argParser.addOption('source',
        abbr: 's', help: 'your source file --default `./res/values/a.json`.');
  }
  @override
  String get description => 'Auto replace string to your value.';

  @override
  String get name => 'strings-replace';

  Logger logger = Logger.standard();

  //参数值
  String value = 'S.of(context)';
  //需要导入的包名
  String import = 'import \'package:school_parent/generated/i18n.dart\';\n';

  Future<int> run() async {
    String replacePath = './lib';
    String arbPath = './res/values/a.json';

    if (argResults['import'] != null) {
      import = argResults['import'];
    }

    if (argResults['var'] != null) {
      value = argResults['var'];
    }

    if (argResults['source'] != null) {
      arbPath = argResults['source'];
    }
    final arbFile = File(arbPath);
    final replaceDirectory = Directory(replacePath);

    final progress = logger.progress('wating: replace string running....');

    final jsonString = await arbFile.readAsString();
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    await readDirectory(replaceDirectory, jsonMap);

    progress.finish(showTiming: true);
    logger.stdout('All finish exit 0');

    return 0;
  }

  Future<void> readDirectory(
      Directory directory, Map<String, dynamic> strings) async {
    final libList = directory.listSync();
    for (final file in libList) {
      // print('scan:${file.path}');
      if (await FileSystemEntity.isDirectory(file.path)) {
        // assetDirectories.add(file.path);
        await readDirectory(Directory(file.path), strings);
      } else {
        if (file.path.endsWith('i18n.dart')) return;

        File mFile = File(file.path);
        //源文件内容
        String sourceContent = await mFile.readAsString();
        //替换后的文本
        String willReplaceContent = await mFile.readAsString();
        bool hasReplaceString = false;

        void collectionString(int start, int end, int ignoreIndex,
            [bool rIgnore = false]) {
          final addOne = rIgnore ? 1 : 0;
          //查找到的字符串
          final stringContent = sourceContent.substring(
              start + ignoreIndex + addOne, end - ignoreIndex);
          //一整条字符串，包含"、r、'
          final rawStringContent = sourceContent.substring(start, end);

          if (hasChinese(stringContent)) {
            hasReplaceString = true;
            //包含$的符号
            if (stringContent.contains('\$')) {
              List<String> params = [];
              final stringScanner = StringScanner(stringContent);
              int stringPosition = stringScanner.position;
              while (!stringScanner.isDone) {
                stringScanner.scan(RegExp(r'\s+'));
                if (stringScanner.scan(RegExp(r'\$\{.*?\}')) ||
                    stringScanner.scan(RegExp(r'\$\w+'))) {
                  String content = stringContent.substring(
                      stringScanner.lastMatch.start,
                      stringScanner.lastMatch.end);
                  params.add(content);
                }
                if (stringScanner.position == stringContent.length) {
                  break;
                }
                if (stringPosition == stringScanner.position) {
                  stringScanner.position = stringPosition + 1;
                }
                stringPosition = stringScanner.position;
              }
              logger.stdout('find:${params.join(',')}');
              final list = strings.entries
                  .where((e) => e.value == stringContent)
                  .toList();
              if (list.isNotEmpty) {
                final key = list[0];
                logger.stdout(
                    'write:S.of(context).${key.key}(${params.map((s) => '"$s"').join(',')})');

                willReplaceContent = willReplaceContent.replaceAll(
                    rawStringContent,
                    'S.of(context).${key.key}(${params.map((s) => '"$s"').join(',')})');
              }
            } else {
              final list = strings.entries
                  .where((e) => e.value == stringContent)
                  .toList();
              if (list.isNotEmpty) {
                final key = list[0];
                logger.stdout('write:$value.${key.key}');
                willReplaceContent = willReplaceContent.replaceAll(
                    rawStringContent, '$value.${key.key}');
              }
            }
          }
        }

        final entities = getStringFromFile(sourceContent);
        for (final entity in entities) {
          collectionString(
              entity.start, entity.end, entity.ignoreNumber, entity.isPrefixR);
        }
        if (hasReplaceString && !willReplaceContent.contains(import)) {
          //添加头文件
          willReplaceContent = '$import$willReplaceContent';
        }
        await mFile.writeAsString(willReplaceContent, mode: FileMode.write);
      }
    }
  }
}
