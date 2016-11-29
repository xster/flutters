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
  //
  Map<String, Input> _inputs = {};
  Map<String, InputValue> _values = {
    'Name': const InputValue(),
    'Race': const InputValue(),
    'Class': const InputValue()
  };

  @override
  Widget build(BuildContext context) {
    _values.keys.forEach((e) {
      _inputs[e] = new Input(
          onChanged: (InputValue _input) {
            setState(() {
              _values[e] = _input;
            });
          },
          value: _values[e],
          labelText: e);
    });

    List boxes = _inputs.keys.toList().map((e) {
      return _inputs[e];
    }).toList();

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Dnd'),
      ),
      body: new Block(children: boxes),
      floatingActionButton: new FloatingActionButton(
        //onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}
