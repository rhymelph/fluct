const stful = r'''import 'package:flutter/material.dart';

class $NAME$ extends StatefulWidget {
  @override
  _$NAME$State createState() => _$NAME$State();
}

class _$NAME$State extends State<$NAME$> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}''';

const stless = r'''import 'package:flutter/material.dart';

class $NAME$ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''';
