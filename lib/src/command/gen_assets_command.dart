import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:fluct/src/fluct_command_runner.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:io/ansi.dart' as io;

const fileName = 'a.dart';

class GenAssetsCommand extends Command<int> {
  GenAssetsCommand() {
    argParser.addOption('assets',
        abbr: 'a', help: 'your asset directory path -- default ./assets');
    argParser.addOption('output',
        abbr: 'o',
        help: 'your output directory path -- default ./lib/generated');
  }
  @override
  String get description => 'Auto generate assets to dart file';
  @override
  String get invocation => '${super.invocation} <path>';

  @override
  String get name => 'gen-assets';

  Future<int> run() async {
    Logger logger = Logger.standard();

    String assetsPath = './assets';
    String outputPath = './lib/generated';
    if (argResults['assets'] != null) {
      assetsPath = argResults['assets'];
    }

    if (argResults['output'] != null) {
      outputPath = argResults['output'];
    }
    logger.stdout('tip: assets directory path in `${assetsPath}`');
    logger.stdout('tip: output directory path in `${outputPath}`');
    final assetsDirectory = Directory(assetsPath);
    final outputDirectory = Directory(outputPath);

    if (!await assetsDirectory.exists()) {
      logger.stdout(io.wrapWith('error: assets file path is not exists.', [io.red]));
      print('exit 0');
      return 0;
    }

    final outputFile = File('${outputDirectory.path}/$fileName');
    if (await outputFile.exists()) {
      await outputFile.delete();
    }
    await outputFile.create(recursive: true);
    Progress progress = logger.progress('waiting: generate running');
    final sink = outputFile.openWrite(mode: FileMode.append);
    sink.writeln('');
    sink.writeln('');
    sink.writeln('// fluct gen-assets command generated.');
    sink.writeln('// author:  rhyme_lph');
    sink.writeln('// github:  https://github.com/rhymelph');
    sink.writeln('// version: $packageVersion');
    sink.writeln('class A {');
    await writeFromDirectory(
        sink,
        assetsDirectory,
        (String asset) =>
            "  static final String  ${formatParams(asset)} = '${asset.substring(2)}';",
        progress);
    sink.writeln(
      '}',
    );
    await sink.close();
    progress.finish(showTiming: true);
    logger.stdout(io.wrapWith(
        'success: generate complete,new file in `${outputFile.path}`',
        [io.green]));
    print(io
        .wrapWith('You can add it in your `pubspec.yaml` file ', [io.yellow]));
    print(io.wrapWith('...............................', [io.yellow]));
    print(io.wrapWith('flutter:', [io.yellow]));
    print(io.wrapWith('  assets:', [io.yellow]));
    for (final assetDirectory in assetDirectories) {
      print(io.wrapWith('    - ${assetDirectory.substring(2)}/', [io.yellow]));
    }
    print(io.wrapWith('...............................', [io.yellow]));
    print('All done exit 0');
    return 0;
  }

  static List<String> assetDirectories = [];

  Future<void> writeFromDirectory(IOSink sink, Directory directory,
      String Function(String string) generated, Progress progress) async {
    final fileList = await directory.listSync();

    for (final file in fileList) {
      if (await FileSystemEntity.isDirectory(file.path)) {
        assetDirectories.add(file.path);
        await writeFromDirectory(
            sink, Directory(file.path), generated, progress);
      } else {
        String fileParentPath = file.parent.path;
        String fileParentName =
            fileParentPath.substring(fileParentPath.lastIndexOf('/'));
        String fileName = file.path.substring(file.path.lastIndexOf('/') + 1);

        if (fileParentName == '/2.0x' ||
            fileParentName == '/3.0x' ||
            fileParentName == '/4.0x' ||
            fileName.startsWith('.')) {
          // print('ignore: file in:${file.path}');
        } else {
          // progress.message ='find: file in :${file.path}';
          sink.writeln(generated(file.path));
        }
      }
    }
    sink.writeln('');
    return null;
  }

//格式化参数
  String formatParams(String path) {
    String formatPath = path.startsWith('./') ? path.substring(2) : path;
    //文件类型
    String type = formatPath.substring(formatPath.lastIndexOf('.') + 1);
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
            )
        .toList();
    pathList = List.generate(
            pathList.length,
            (int index) => index == 0
                ? pathList[index]
                : index == pathList.length - 1
                    ? '${pathList[index][0].toUpperCase()}${pathList[index].substring(1, pathList[index].indexOf('.'))}'
                    : '${pathList[index][0].toUpperCase()}${pathList[index].substring(1).toLowerCase()}')
        .toList();
    return pathList.join('');
  }
}
