import 'dart:io' show File;
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

//Entry point
void main() {
  runApp(
    new MaterialApp(
      title: 'Rabbit numbers',
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

  @override
  void initState() {
    super.initState();
    //do stuff when state is initialized
  }

  //html localhost
  Future<File> _get_data() async {
    // get the path to the document directory.
    String dir = (await PathProvider.getApplicationDocumentsDirectory()).path;
    return new File('$dir/data.txt');
  }

  //make toasts
  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  int move_cost = 20;

  //Put it all together.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
            title: new Text('Rabbit Numbers'),
            actions: <Widget>[
              new IconButton(
                  onPressed: () {
                    setState(() {
                      move_cost *= 2;
                    });
                  },
                  tooltip: 'Double up for $move_cost',
                  icon: new Icon(Icons.add)),
              new PopupMenuButton<String>(
                  onSelected: showInSnackBar,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuItem<String>>[
                        new PopupMenuItem<String>(
                            value: 'Toolbar menu',
                            child: new Text('Toolbar menu')),
                        new PopupMenuItem<String>(
                            value: 'Right here', child: new Text('Right here')),
                        new PopupMenuItem<String>(
                            value: 'Hooray!', child: new Text('Hooray!')),
                      ])
            ],
            leading: new Image.asset('assets/nuRabbit.png')),
        body: new Padding(
            padding: const EdgeInsets.all(16.0),
            child: new Block(children: [
              new LinearProgressIndicator(),
              new Image.asset('assets/nuRabbit.png')
            ])),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {},
          tooltip: 'Increment',
          child: new Icon(Icons.add),
        ));
  }
}
