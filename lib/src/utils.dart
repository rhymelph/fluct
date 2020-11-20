import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:fluct/src/entity/string_entity.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:string_scanner/string_scanner.dart';

const appName = 'fluct';

// The path to the root directory of the sdk
final String _sdkDir = (() {
  // The Dart executable is in "/path/to/sdk/bin/dart", so two levels up is
  // "/path/to/sdk".
  var aboveExecutable = p.dirname(p.dirname(Platform.resolvedExecutable));
  assert(FileSystemEntity.isFileSync(p.join(aboveExecutable, 'version')));
  return aboveExecutable;
})();

final String dartPath = p.join(_sdkDir, 'bin', 'dart');

final String pubSnapshot =
    p.join(_sdkDir, 'bin', 'snapshots', 'pub.dart.snaphot');
final String pubPath =
    p.join(_sdkDir, 'bin', Platform.isWindows ? 'pub.bat' : 'pub');

//翻译文件
Future<String> transform(String content) async {
  final result = await http.get(
      'http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=$content');
  final resultString = result.body;
  // print(resultString);
  return json.decode(resultString)['translateResult'][0][0]['tgt'];
}

//是否含有中文
bool hasChinese(String string) =>
    string.isNotEmpty && RegExp('[\u4e00-\u9fa5]').hasMatch(string);

//是否为英文大写
bool isUpperCase(int c) => c >= 65 && c <= 90;

//构建Dart文件名字
String formatUnderlineName(String name) {
  final codeList = name.codeUnits;
  List<int> result = [];
  for (int i = 0; i < codeList.length; i++) {
    final code = codeList[i];
    if (isUpperCase(code) && i != 0) {
      result.addAll('_'.codeUnits);
    }
    result.addAll(String.fromCharCode(code).toLowerCase().codeUnits);
  }
  return String.fromCharCodes(result);
}

//查找所有字符串
List<StringCommendEntity> getStringFromFile(String fileContent) {
  List<StringCommendEntity> entities = [];
  final scanner = StringScanner(fileContent);
  int lastPosition = scanner.position;
  int contentLength = fileContent.length;
  while (!scanner.isDone) {
    scanner.scan(RegExp(r'\s+'));
    if (scanner.scan(RegExp(r'"""(?:[^"\\]|\\(.|\n))*"""')) ||
        scanner.scan(RegExp(r"'''(?:[^'\\]|\\(.|\n))*'''"))) {
      final ignoreIndex = 3;
      entities.add(StringCommendEntity(
        scanner.lastMatch.start,
        scanner.lastMatch.end,
        ignoreIndex,
      ));
      continue;
    }

    if (scanner.scan(RegExp(r'r"""(?:[^"\\]|\\(.|\n))*"""')) ||
        scanner.scan(RegExp(r"r'''(?:[^'\\]|\\(.|\n))*'''"))) {
      final ignoreIndex = 3;
      entities.add(StringCommendEntity(
        scanner.lastMatch.start,
        scanner.lastMatch.end,
        ignoreIndex,
        true,
      ));
      continue;
    }

    if (scanner.scan(RegExp(r'".*?"')) || scanner.scan(RegExp(r"\'.*?\'"))) {
      final ignoreIndex = 1;
      entities.add(StringCommendEntity(
        scanner.lastMatch.start,
        scanner.lastMatch.end,
        ignoreIndex,
      ));

      continue;
    }

    if (scanner.scan(RegExp(r'r".*?"')) || scanner.scan(RegExp(r"r\'.*?\'"))) {
      final ignoreIndex = 1;
      entities.add(StringCommendEntity(
          scanner.lastMatch.start, scanner.lastMatch.end, ignoreIndex, true));
      continue;
    }
    if (scanner.position == contentLength) {
      break;
    }
    if (lastPosition == scanner.position) {
      scanner.position = lastPosition + 1;
    }
    lastPosition = scanner.position;
  }
  return entities;
}
