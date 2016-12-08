import 'dart:io' show File;
import 'dart:math' show Random;
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

String title = 'Rabbit numbers';
GlobalKey<ScaffoldState> _scaffoldKey;
Random rand = new Random();
State app_state;

List<Tile> tiles = []; //tile container
Tile_state last_sel = null; //last selected tile

int move_cost = 20; //amount of score it costs to do a special move
int tile_count = 64; //starting number of tiles
int score = 0; //current score

//make toasts
void showInSnackBar(String value) {
  _scaffoldKey.currentState
      .showSnackBar(new SnackBar(content: new Text(value)));
}

void snack(_value) => showInSnackBar('${_value}');

//the math is done expecting 8 wide
void check_tiles(Tile_state new_sel) {
  if (new_sel.matched) {
    //do nothing
  } else if (last_sel == null) {
    new_sel.focused = true;
    last_sel = new_sel;
  } else if (last_sel == new_sel) {
    //remove last sel, unselect
    new_sel.focused = false;
    last_sel = null;
  } else if (last_sel.value == new_sel.value ||
      last_sel.value + new_sel.value == 10) {
    //match and hide
    //int sel_index = tiles.indexOf(new_sel.config);
    //int last_index = tiles.indexOf(last_sel.config);

    Map<String, int> sel_index = {
      'row': (tiles.indexOf(new_sel.config) / 8).floor(),
      'column': (tiles.indexOf(new_sel.config) % 8),
      'index': tiles.indexOf(new_sel.config)
    };

    Map<String, int> last_index = {
      'row': (tiles.indexOf(last_sel.config) / 8).floor(),
      'column': (tiles.indexOf(last_sel.config) % 8),
      'index': tiles.indexOf(last_sel.config)
    };

    int direction = 1; //will be 1 or -1 to check left or right directions
    bool found = false; //will be true if found match
    int start = sel_index['index']; //start point for left to right check

    if (sel_index['index'] > last_index['index']) direction = -1;

    while (start != last_index['index']) {
      start += direction; //lets check the nest spot

      if (start == last_index['index']) {
        found = true;
      } else if (tiles[start].state.matched != true) {
        //if found non blank tile but not last selected one
        //behave as no match
        break;
      }
    }

    //check up and down
    if (last_index['column'] == sel_index['column'] && !found) {
      start = sel_index['row'];
      direction = 1;
      if (sel_index['row'] > last_index['row']) {
        direction = -1;
      }
      
      while (start != last_index['row']) {
        start += direction;
        //snack(start + (sel_index['column'] * 8));
        if (start == last_index['row']) {
          found = true;
        } else if (tiles[start + (sel_index['column'] * 8)].state.matched !=
            true) {
          //if found non blank tile but not last selected one
          //behave as no match
          break;
        }
      }
    }

    if (found) {
      new_sel
        ..focused = false
        ..matched = true;

      last_sel.setState(() {
        last_sel
          ..focused = false
          ..matched = true;
      });
      
      app_state.setState((){
        if(new_sel.value == last_sel.value){
        score+=new_sel.value;
      }else{
        score+=10;
      }
      });
      
      
      last_sel = null;
    } else {
      new_sel.focused = true;

      //update last tile
      last_sel.setState(() {
        last_sel.focused = false;
      });
      last_sel = new_sel;
    }
  } else {
    //no match, but not matching self
    new_sel.focused = true;

    //update last tile
    last_sel.setState(() {
      last_sel.focused = false;
    });
    last_sel = new_sel;
  }
}

//Entry point
void main() {
  runApp(
    new MaterialApp(
      title: title,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FlutterDemo(title: title),
    ),
  );
}

//base stateful widget
class FlutterDemo extends StatefulWidget {
  FlutterDemo({this.title, Key key}) : super(key: key);

  final String title;

  @override
  _FlutterDemoState createState() => new _FlutterDemoState();
}

//base stateful widget's state
class _FlutterDemoState extends State<FlutterDemo> {
  @override
  void initState() {
    super.initState();
    //do stuff when state is initialized
    _scaffoldKey = new GlobalKey<ScaffoldState>();

    while (tile_count-- > 0) {
      tiles.add(new Tile(value: rand.nextInt(9) + 1));
    }
    
    app_state = this;
  }

  //html localhost
  //get data stored to get and save data
  Future<File> _get_data() async {
    // get the path to the document directory.
    String dir = (await PathProvider.getApplicationDocumentsDirectory()).path;
    return new File('$dir/data.txt');
  }

  //Put it all together.
  @override
  Widget build(BuildContext context) {
    //fills in the blank spaces with blank cards at the end of the grid
    int fill = -(tiles.length % 8 - 8);
    if (fill != 8) while (fill-- > 0) tiles.add(new Tile());

    //builds grid out in rows
    List<Widget> row = [];
    List<Widget> rows = [];
    int _count = tiles.length;

    while (_count-- > 0) {
      row.add(tiles[tiles.length - _count - 1]);
      if (_count % 8 == 0) {
        rows.add(new Row(
            mainAxisAlignment: MainAxisAlignment.center, children: row));
        row = [];
      }
    }

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
            title: new Text(score==0?config.title:'Score: ${score}'),
            actions: <Widget>[
              /*new IconButton(
                  onPressed: () {
                    setState(() {
                      move_cost *= 2;
                    });
                  },
                  tooltip: 'Undo',
                  icon: new Icon(Icons.undo)),*/
              new IconButton(
                  onPressed: () {
                    setState(() {
                      move_cost *= 2;
                    });
                  },
                  tooltip: 'Double up for $move_cost',
                  icon: new Icon(Icons.add)),
              new IconButton(
                  onPressed: () {
                    setState(() {
                      move_cost *= 2;
                    });
                  },
                  tooltip: 'Shuffle for $move_cost',
                  icon: new Icon(Icons.shuffle)),
              new IconButton(
                  onPressed: () {
                    setState(() {
                      //restart
                      tile_count=64;
                      score = 0;
                      move_cost = 20;
                      tiles=[];
                      while (tile_count-- > 0) {
                        tiles.add(new Tile(value: rand.nextInt(9) + 1));
                      }
                    });
                  },
                  tooltip: 'Restart',
                  icon: new Icon(Icons.refresh)),
              new IconButton(
                  onPressed: () {
                    setState(() {
                      snack('some help menu');
                    });
                  },
                  tooltip: 'Help',
                  icon: new Icon(Icons.help_outline))
            ],
            leading: new Image.asset('assets/nuRabbit.png')),
        body: new ScrollableList(children: rows, itemExtent: 60.0),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            showInSnackBar('${tiles.map((e)=>e.value)}');
          },
          tooltip: 'Increment',
          child: new Icon(Icons.add),
        ));
  }
}

//yay new widget
class Tile extends StatefulWidget {
  Tile({this.value: 0, Key key}) : super(key: key);

  int value;
  State<Tile> state;

  @override
  Tile_state createState() {
    state = new Tile_state();
    return state;
  }
}

class Tile_state extends State<Tile> {
  Color default_color = Colors.white;
  Color focused_color = Colors.cyan[500];
  int value;
  bool focused = false;
  bool matched = false;

  @override
  void initState() {
    super.initState();
    value = config.value; //shorter reference to value
    //default to blank card for filling spaces
    if (value == 0) matched = true;
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
        color: focused ? focused_color : default_color,
        child: new InkWell(
            onTap: () {
              setState(() {
                check_tiles(this);
              });
            },
            child: new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new Opacity(
                    child: new Text('${value}'),
                    opacity: matched ? 0.0 : 1.0))));
  }
}
