import 'package:flutter/material.dart';

//Entry point
void main() {
  runApp(
    new MaterialApp(
      title: 'Dnd',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FlutterDemo(),
    ),
  );
}

//base stateful widget
class FlutterDemo extends StatefulWidget {
  FlutterDemo({Key key}) : super(key: key);

  @override
  _FlutterDemoState createState() => new _FlutterDemoState();
}

//base stateful widget's state
class _FlutterDemoState extends State<FlutterDemo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //holds the values of textboxes
  Map<String, List> _values = {
    'Name': const InputValue(),
    'Race': const InputValue(),
    'Class': const InputValue()
  };

  //general input box maker
  Input make_input(String e) {
    return new Input(
        onChanged: (InputValue _input) {
          setState(() {
            _values[e] = _input;
          });
        },
        value: _values[e],
        labelText: '$e: ${_values[e].text}',
        onSubmitted: (InputValue _input) {
          /*showDialog(
              context: context,
              child: new AlertDialog(
                  title: new Text('test'),
                  content: new Text(_input.text)));*/

          showInSnackBar(_input.text);
        });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void showMenuSelection(String value) {
    //if (<String>[_simpleValue1, _simpleValue2, _simpleValue3].contains(value))
    //  _simpleValue = value;
    showInSnackBar('You selected: $value');
  }

  //Put it all together.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: new Text('Dnd'), actions: <Widget>[
          new PopupMenuButton<String>(
              onSelected: showMenuSelection,
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    new PopupMenuItem<String>(
                        value: 'Toolbar menu', child: new Text('Toolbar menu')),
                    new PopupMenuItem<String>(
                        value: 'Right here', child: new Text('Right here')),
                    new PopupMenuItem<String>(
                        value: 'Hooray!', child: new Text('Hooray!')),
                  ])
        ]),
        body: new Block(children: [make_input('Name')]),
        floatingActionButton: new FloatingActionButton(
          //onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: new Icon(Icons.add),
        ));
  }
}
