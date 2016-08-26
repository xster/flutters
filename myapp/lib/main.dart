import 'package:flutter/material.dart';

String title = 'Flutter Learning stuff';

//entry point
void main() {
  runApp(new MaterialApp(
      title: title,
      theme: new ThemeData(primarySwatch: Colors.red),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _counter = 0;

  //builder functions used to expose context for Scaffold.of(context) options.
  //without this structure, you cannot do things like snackbars

  //builder function for body
  Widget buildBody(BuildContext context) {
    return new Center(child: new Text('banana tapped$_counter'));
  }

  //builder function for floating action
  Widget buildFab(BuildContext context) {
    return new FloatingActionButton(onPressed: () {
      //set state rebuilds a stated whidget
      setState(() {
        _counter++;

        //toast options
        /*Scaffold
            .of(context)
            .showSnackBar(new SnackBar(content: new Text('Opened')));*/
      });

      _scaffoldKey.currentState
          .showBottomSheet /*<Null>*/ ((BuildContext context) {
        final ThemeData themeData = Theme.of(context);
        return new Container(
            decoration: new BoxDecoration(
                border: new Border(
                    top: new BorderSide(color: themeData.disabledColor))),
            child: new Padding(
                padding: const EdgeInsets.all(32.0),
                child: new Block(children: <Widget>[
                  new Text('Short bottom message',
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          color: themeData.accentColor, fontSize: 24.0))
                ])));
      }).closed.then((_) {
        setState(() {
          // re-enable the button
          //_showBottomSheetCallback = showBottomSheet;
          Scaffold
              .of(context)
              .showSnackBar(new SnackBar(content: new Text('Closed')));
        });
      });
    }, tooltip: 'Increment', child: new Icon(Icons.add));
  }

  //main build point
  //scaffold is a pre-bake
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: new Text(title)),
        body: new Builder(builder: buildBody),
        floatingActionButton: new Builder(builder: buildFab));
  }
}
