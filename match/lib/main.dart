import 'package:flutter/material.dart';

String title = 'Match';

//entry point
void main() {
  runApp(new MaterialApp(
      title: title,
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new FlutterDemo()));
}

//base widget for the whole app
//I guess this is needed
class FlutterDemo extends StatefulWidget {
  FlutterDemo({Key key}) : super(key: key);

  @override
  _FlutterDemoState createState() => new _FlutterDemoState();
}

//Demo app itself
class _FlutterDemoState extends State<FlutterDemo> {
  int _counter = 0;
  int _button_presses = 0;
  List<String> choices = '0011223344556677'.split('').toList()..shuffle();

  //builder function for body
  Widget buildBody(BuildContext context) {
    List<List<Widget>> buttons = new List<List<Widget>>();
    List<Widget> rows = new List<Widget>();

    int i = 4;
    int j = 4;

    while (i-- > 0) {
      buttons.add(new List<Widget>());
      while (j-- > 0) {
        buttons.last.add(new Padding(
            child: new RaisedButton(
                child: new Text('${choices[i*4+j]}'),
                onPressed: () {
                  setState(() {
                    _button_presses++;
                  });
                }),padding:new EdgeInsets.all(4.0)));
      }
      rows.add(
          new Flex(mainAxisSize: MainAxisSize.min, children: buttons.last));
      j = 4;
    }

    //return new Center(child: new Text('I\'ve been tapped tapped $_counter'));
    return new Center(
        child: new Flex(direction: FlexDirection.vertical, children: rows));
  }

  //builder function for floating action
  Widget buildFab(BuildContext context) {
    return new FloatingActionButton(
        onPressed: () {
          //set state rebuilds a stated whidget
          setState(() {
            _counter++;

            //toast options
            /*Scaffold
            .of(context)
            .showSnackBar(new SnackBar(content: new Text('Opened')));*/
          });
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add));
  }

  //main build point
  //scaffold is a pre-bake
  //using builder functions is how you can allow snackbars to work
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text(title)),
        body: new Builder(builder: buildBody)
        //    floatingActionButton: new Builder(builder: buildFab)
        );
  }
}
