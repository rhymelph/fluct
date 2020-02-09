![](https://user-gold-cdn.xitu.io/2020/2/9/170286606a894a28?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)
# fluct
[![pub package](https://img.shields.io/pub/v/fluct.svg)](https://pub.dartlang.org/packages/fluct)

A command-lint tool for help develop flutter application.

## Installation

`fluct` is not meant to be used as a dependency,Instead,it should be "activated".

```
$ pub global activate fluct
# or
$ flutter pub global activate fluct
```
or you can get it form github.

```
$ pub global activate -sgit https://github.com/rhymelph/fluct
# or
$ flutter pub global activate -sgit https://github.com/rhymelph/fluct
```
Learn more about activating and using packages (here)[https://dart.dev/tools/pub/cmd/pub-global]

## Usage
`fluct` provides only one commands:`create`.

### `fluct create`

```dart
Help Flutter application create a new file

Usage: fluct create [arguments] <path>
-h, --help            Print this usage information.
-t, --type            
          [custom]    Create a new file about custom widget in 'fluct.yaml'
          [stful]     Create a new file about StatefulWidget
          [stless]    Create a new file about StatelessWidget

-a, --arg             create a new file about your custom widget use arg in 'fluct.yaml'

Run "fluct help" to see global options.
```
#### example
create a new file about StateFulWidget.
```
$ fluct create -t stful home_page
Create a new file about StatefulWidget
create class HomePage
create success
exit 0
```
End,you can find `./home_page.dart`
```dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```
#### custom widget
Create a new file about custom widget in 'fluct.yaml'
```fluct.yaml
inh: |
  import 'package:flutter/material.dart';

  class $NAME$ extends InheritedWidget {
    const $NAME$({
      Key key,
      @required Widget child,
    })  : assert(child != null),
          super(key: key, child: child);

    static $NAME$ of(BuildContext context) {
      return context.dependOnInheritedWidgetOfExactType(aspect: $NAME$) as $NAME$;
    }

    @override
    bool updateShouldNotify($NAME$ old) {
      return false;
    }
  }
```
inh: is your arg.
import..: is your custom widget,use `$NAME$` will replace your name by file name,and the first word will uppercase,such as: home_page will become HomePage

as last, you can use this command-line.
```
fluct create -t custom -a inh home_page_inherited
```
Have a nice day 。
