import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:fluct/src/fluct_command_runner.dart';
import 'package:fluct/src/utils.dart';
import 'package:io/ansi.dart' as io;

const fileName = 'a.dart';

/// 自动获取项目下的资源文件，并生成A.dart文件
class AssetsGenCommand extends Command<int> {
  AssetsGenCommand() {
    argParser.addOption('input',
        abbr: 'i', help: 'Your input directory path -- default `./assets`.');
    argParser.addOption('output',
        abbr: 'o',
        help: 'Your output directory path -- default `./lib/generated`.');
    argParser.addOption('ignore', help: 'Ignore your prefix path.');
    argParser.addFlag('rename',
        abbr: 'r',
        help: 'Include chinese filename will be rename to English filename.');
    argParser.addFlag('collect',
        abbr: 'c',
        help:
            'Collect filename include @2x/@3x/@4x strings file to /2.0x,/3.0x,/4.0x directory.');
    argParser.addFlag('list', abbr: 'l', help: 'Collect all image into list');
  }

  @override
  String get description => 'Auto generate assets to dart file.';

  @override
  String get invocation => '${super.invocation} <command> <path>';

  @override
  String get name => 'assets-gen';
  final Logger logger = Logger.standard();

  Future<int> run() async {
    var ignorePaths = <String>[];
    var inputPath = './assets';
    var outputPath = './lib/generated';
    var isCollectList = false;
    if (argResults['input'] != null) {
      inputPath = argResults['input'];
    }

    if (argResults['output'] != null) {
      outputPath = argResults['output'];
    }

    if (argResults['ignore'] != null) {
      ignorePaths = (argResults['ignore'].toString()).split(',');
    }
    if (argResults['list'] != null) {
      isCollectList = true;
    }
    logger.stdout('tip: input directory path in `${inputPath}`');
    logger.stdout('tip: output directory path in `${outputPath}`');
    final inputDirectory = Directory(inputPath);
    final outputDirectory = Directory(outputPath);

    if (!await inputDirectory.exists()) {
      logger.stdout(
          io.wrapWith('error: input directory path is not exists.', [io.red]));
      print('exit 0');
      return 0;
    }
    final progress = logger.progress('waiting: generate running');
    final outputFile = File('${outputDirectory.path}/$fileName');
    if (await outputFile.exists()) {
      await outputFile.delete();
    }
    await outputFile.create(recursive: true);
    final sink = outputFile.openWrite(mode: FileMode.append);
    sink.writeln('');
    sink.writeln('');
    sink.writeln('// fluct assets-gen command generated.');
    sink.writeln('// author:  rhyme_lph');
    sink.writeln('// github:  https://github.com/rhymelph');
    sink.writeln('// version: $packageVersion');
    sink.writeln('class A {');
    var assetList = <String>[];

    await writeFromDirectory(sink, inputDirectory, (String asset) {
      if (asset.isEmpty) return '';

      final paramsName = '${formatParams(asset)}';
      assetList.add(paramsName);
      return asset.isEmpty
          ? ''
          : "  static final String  $paramsName = '${getParamsValue(asset.substring(2), ignorePaths)}';";
    }, progress);
    if (isCollectList) {
      sink.writeln('''  static List<String> get allList => [
${assetList.map((e) => '        $e,').join('\n')}
      ];''');
    }
    sink.writeln(
      '}',
    );
    await sink.close();
    progress.finish(showTiming: true);
    logger.stdout(io.wrapWith(
        'success: generate complete,new file in `${outputFile.path}`',
        [io.green]));
    logger.stdout(io
        .wrapWith('You can add it in your `pubspec.yaml` file ', [io.yellow]));
    logger.stdout(io.wrapWith('...............................', [io.yellow]));
    logger.stdout(io.wrapWith('flutter:', [io.yellow]));
    logger.stdout(io.wrapWith('  assets:', [io.yellow]));
    for (final assetDirectory in assetDirectories) {
      logger.stdout(
          io.wrapWith('    - ${assetDirectory.substring(2)}/', [io.yellow]));
    }
    logger.stdout(io.wrapWith('...............................', [io.yellow]));
    logger.stdout('All done exit 0');
    return 0;
  }

  String getParamsValue(String value, List<String> ignorePath) {
    var result = value;
    ignorePath.forEach((s) {
      result = result.replaceFirst(s, '');
    });
    return result;
  }

  static List<String> assetDirectories = [];

  Future<void> writeFromDirectory(IOSink sink, Directory directory,
      String Function(String string) generated, Progress progress) async {
    final fileList = directory.listSync();

    for (final myfile in fileList) {
      var _file = myfile;

      if (await FileSystemEntity.isDirectory(_file.path)) {
        var directoryName =
            _file.path.substring(_file.path.lastIndexOf('/') + 1);
        if (hasChinese(directoryName) && argResults['rename'] == true) {
          var fileParentPath = _file.parent.path;
          final sourceName = directoryName;
          logger.stdout('tip: will transform name :$sourceName');
          var transformName = await transform(sourceName);
          transformName = transformName.replaceAll(' ', '_');
          logger.stdout('tip: transform result :$transformName');
          final d = Directory(_file.path);
          _file = await d.rename('${fileParentPath}/$transformName');
        }
        assetDirectories.add(_file.path);
        await writeFromDirectory(
            sink, Directory(_file.path), generated, progress);
      } else {
        final fileParentPath = _file.parent.path;
        final fileParentName =
            fileParentPath.substring(fileParentPath.lastIndexOf('/'));
        var fileName = _file.path.substring(_file.path.lastIndexOf('/') + 1);

        if (fileParentName == '/2.0x' ||
            fileParentName == '/3.0x' ||
            fileParentName == '/4.0x' ||
            fileName.startsWith('.')) {
          if (fileName.contains('@3x') || fileName.contains('@2x')) {
            final newFileName =
                fileName.replaceAll('@3x', '').replaceAll('@2x', '');
            _file = await _file.rename('${fileParentPath}/$newFileName');
            //包含中文，进行翻译
            if (hasChinese(newFileName) && argResults['rename'] == true) {
              final sourceName =
                  newFileName.substring(0, newFileName.lastIndexOf('.'));
              final sourceType =
                  newFileName.substring(newFileName.lastIndexOf('.'));
              logger.stdout('tip: will transform name :$sourceName');
              var transformName = await transform(sourceName);
              transformName = transformName.replaceAll(' ', '_');
              logger.stdout('tip: transform result :$transformName');
              _file = await _file
                  .rename('${fileParentPath}/$transformName$sourceType');
            }
          } else {
            //包含中文，进行翻译
            if (hasChinese(fileName) && argResults['rename'] == true) {
              final sourceName =
                  fileName.substring(0, fileName.lastIndexOf('.'));
              final sourceType = fileName.substring(fileName.lastIndexOf('.'));
              logger.stdout('tip: will transform name :$sourceName');
              var transformName = await transform(sourceName);
              transformName = transformName.replaceAll(' ', '_');
              logger.stdout('tip: transform result :$transformName');
              _file = await _file
                  .rename('${fileParentPath}/$transformName$sourceType');
            }
          }
          // print('ignore: file in:${file.path}');
        } else {
          // progress.message ='find: file in :${file.path}';
          if (argResults['collect'] == true &&
              (fileName.contains('@3x') ||
                  fileName.contains('@2x') ||
                  fileName.contains('@4x'))) {
            final newFileName = fileName
                .replaceAll('@3x', '')
                .replaceAll('@2x', '')
                .replaceAll('@4x', '');
            var collectName = '/2.0x';
            if (fileName.contains('@3x')) {
              collectName = '/3.0x';
            } else if (fileName.contains('@4x')) {
              collectName = '/4.0x';
            }
            final newFile = File('${fileParentPath}$collectName/$newFileName');
            if (!newFile.existsSync()) {
              newFile.createSync(recursive: true);
            }
            await newFile.writeAsBytes(await File(_file.path).readAsBytes());
            await _file.delete();
            _file = newFile;
            //包含中文，进行翻译
            if (hasChinese(newFileName) && argResults['rename'] == true) {
              final sourceName =
                  newFileName.substring(0, newFileName.lastIndexOf('.'));
              final sourceType =
                  newFileName.substring(newFileName.lastIndexOf('.'));
              logger.stdout('tip: will transform name :$sourceName');
              var transformName = await transform(sourceName);
              transformName = transformName.replaceAll(' ', '_');
              logger.stdout('tip: transform result :$transformName');
              _file = await newFile.rename(
                  '${fileParentPath}$collectName/$transformName$sourceType');
            }
            // sink.writeln(generated(_file.path));
          } else {
            //包含中文，进行翻译
            if (hasChinese(fileName) && argResults['rename'] == true) {
              final sourceName =
                  fileName.substring(0, fileName.lastIndexOf('.'));
              final sourceType = fileName.substring(fileName.lastIndexOf('.'));
              logger.stdout('tip: will transform name :$sourceName');
              var transformName = await transform(sourceName);
              transformName = transformName.replaceAll(' ', '_');
              logger.stdout('tip: transform result :$transformName');
              _file = await _file
                  .rename('${fileParentPath}/$transformName$sourceType');
            }
            sink.writeln(generated(_file.path));
          }
        }
      }
    }
    sink.writeln('');
    return null;
  }

//格式化参数
  String formatParams(String path) {
    String formatPath = path.startsWith('./') ? path.substring(2) : path;
    if (formatPath.indexOf('.') != -1) {
      //文件类型
      // String type = formatPath.substring(formatPath.lastIndexOf('.') + 1);
      //去掉类型
      formatPath = formatPath.substring(0, formatPath.lastIndexOf('.'));
    }
    List<String> pathList = formatPath
        .replaceAll('/', '_')
        .split('_')
        .map((s) => s
            .replaceAll('(', '')
            .replaceAll(')', '')
            .replaceAll(' ', '_')
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('{', '')
            .replaceAll('}', '')
            .replaceAll('+', '_')
            .replaceAll('-', '_')
            .replaceAll('*', '_')
            .replaceAll(',', '_')
            .replaceAll('.', '_')
            .replaceAll('！', '_'))
        .toList();
    pathList = List.generate(
            pathList.length,
            (int index) => index == 0
                ? pathList[index]
                : index == pathList.length - 1
                    ? pathList[index].isEmpty
                        ? ''
                        : '${pathList[index][0].toUpperCase()}${pathList[index].substring(1)}'
                    : pathList[index].isEmpty
                        ? ''
                        : '${pathList[index][0].toUpperCase()}${pathList[index].substring(1).toLowerCase()}')
        .toList();
    return pathList.join('');
  }
}
