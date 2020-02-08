import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fluct/constant.dart';
import 'package:yaml/yaml.dart' as yaml;
class CreateCommand extends Command{

  final allowedHelp = {
      'stful':'create a new file about StatefulWidget',
      'stless':'create a new file about StatelessWidget',
      'custom':'create a new file about custom',
    };

  @override
  String get description => 'create a new file';

  @override
  String get name => 'create';

  CreateCommand(){
    argParser.addOption('type',abbr:'t',allowed: [
      'stful',
      'stless',
      'custom',
    ],allowedHelp: allowedHelp
    );
    argParser.addOption('arg',abbr:'a',help:'create a new file about your custom arg');
  }
  void run(){
    final type = argResults['type'];
    final path = argResults.arguments.last;
    if(allowedHelp.containsKey(type)){
      print(allowedHelp[type]);
      switch (type) {
        case 'stful':
        createFile(path,stful);
          break;
        case 'stless':
        createFile(path,stful);
          break;
        case 'custom':
        createCustomFile(path);
          break;
      }
    }else{
      print(usage);
    }
  }

  void createCustomFile(String path){
    String arg = argResults['arg'];
    
    if(arg.isEmpty){
      print("error:please enter your arg in 'fluct.yaml' ");
      print('exit 0');
      exit(64);
    }
    final fluctFile = File('fluct.yaml');
    if(!fluctFile.existsSync()){
      print("error:please create your 'fluct.yaml' ");
      print('exit 0');
      exit(64);
    }
    final yamlContent =yaml.loadYaml(fluctFile.readAsStringSync());
    final content = yamlContent[arg];
    if(content == null){
       print("error:not found '$arg' in your 'fluct.yaml' ");
      print('exit 0');
      exit(64);
    }else{
      createFile(path, content.toString());
    }
  }


  void createFile(String path,String model){
    var className = '';
    var name;

    if(path.contains('/')){
      name = path.substring(path.lastIndexOf('/')+1);
      
    }else{
      name = path;
    }
    final works = name.split('_');
      for(final work in works){
        if(work.isNotEmpty){
          className += work[0].toUpperCase()+work.substring(1);
        }
      }
    print('create class $className');
    if(className.isEmpty){
      print('error:please enter your path');
      print('exit 0');
      exit(64);
    }
    final file = File('$path.dart');
    if(!file.existsSync()){
      file.createSync(recursive:true);
    }
    file.writeAsStringSync(model.replaceAll(r'$NAME$', className));
    print('create success');
    print('exit 0');
  }
}