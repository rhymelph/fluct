import 'dart:io';

import 'package:fluct/src/utils.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:test/test.dart';

void main() {
  test('calculate', () async {
    String parseContent = r'const s2 = "双引号";';
    final _scanner = StringScanner(parseContent);
    int lastPosition = _scanner.position;
    while (!_scanner.isDone) {
      print(_scanner.position);
      _scanner.scan(RegExp(r'\s+'));

      if (_scanner.scan(RegExp(r'".*"'))) {
        final ignoreIndex = 1;
        final resultContent = parseContent.substring(
            _scanner.lastMatch.start + ignoreIndex,
            _scanner.lastMatch.end - ignoreIndex);

        if (resultContent.isNotEmpty &&
            RegExp('[\u4e00-\u9fa5]').hasMatch(resultContent)) {
          // String transformResult = await transform(con);
          // print(con);
          print(resultContent);
        }
        continue;
      }
      if(_scanner.position == parseContent.length){
        _scanner.expectDone();
        break;
      }
      if(lastPosition == _scanner.position){
        _scanner.position =lastPosition+1;
      }
      lastPosition = _scanner.position;

    }
  });
  test('format file name', () async {
    String content = "AFormatCode";
    String result = formatUnderlineName(content);
    print(result);
  });

}
