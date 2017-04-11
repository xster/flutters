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
Tile last_sel = null; //last selected tile

int move_cost = 20; //amount of score it costs to do a special move
int tile_count = 64; //starting number of tiles
int score = 0; //current score
int high_score = 0;
bool undoable = false; //can undo work?

//make toasts
void showInSnackBar(String value) {
  _scaffoldKey.currentState
      .showSnackBar(new SnackBar(content: new Text(value)));
}

//short hand to snackbar
void snack(_value) => showInSnackBar('${_value}');

//show move message when a special move has been made
void make_move_message() {
  snack('Next special move will cost $move_cost');
}

//get data stored to get and save data
Future<File> _get_data() async {
  String dir = (await PathProvider.getApplicationDocumentsDirectory()).path;
  return new File('$dir/data.txt');
}

//save the state of the game
void save_file(_callback) {
  _get_data().then((File _file) {
    String tile_data = tiles.map((e) => e.matched ? 0 : e.value).join('\n');
    _file
        .writeAsString('$score\n$move_cost\n$high_score\n$tile_data')
        .then(_callback);
  });
}

//the math is done expecting 8 wide
//also handles win condition.
void check_tiles(Tile new_sel) {
  if (new_sel.matched) {
    //do nothing
  } else if (last_sel == null) {
    //first tile focused
    new_sel.focused = true;
    last_sel = new_sel;
  } else if (last_sel == new_sel) {
    //selected already selected tile
    new_sel.focused = false;
    last_sel = null;
  } else if (last_sel.value == new_sel.value ||
      last_sel.value + new_sel.value == 10) {
    //check for match and hide

    //get the locations of the two selected tiles
    Map<String, int> sel_index = {
      'row': (tiles.indexOf(new_sel) / 8).floor(),
      'column': (tiles.indexOf(new_sel) % 8),
      'index': tiles.indexOf(new_sel)
    };

    Map<String, int> last_index = {
      'row': (tiles.indexOf(last_sel) / 8).floor(),
      'column': (tiles.indexOf(last_sel) % 8),
      'index': tiles.indexOf(last_sel)
    };

    int direction = 1; //will be 1 or -1 to check left or right directions
    bool found = false; //will be true if found match
    int start = sel_index['index']; //start point for left to right check

    if (sel_index['index'] > last_index['index']) direction = -1;

    while (start != last_index['index']) {
      start += direction; //lets check the nest spot

      if (start == last_index['index']) {
        found = true;
      } else if (tiles[start].matched != true) {
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
        if (start == last_index['row']) {
          found = true;
        } else if (tiles[(start * 8) + sel_index['column']].matched != true) {
          //if found non blank tile but not last selected one
          //behave as no match
          break;
        }
      }
    }

    if (found) {
      //callback structure to allow ui to update after saving the current board
      save_file((_file) {
        //update both tiles
        new_sel.state.setState(() {
          new_sel
            ..focused = false
            ..matched = true;
        });

        last_sel.state.setState(() {
          last_sel
            ..focused = false
            ..matched = true;
        });

        //refresh app bar for new score
        app_state.setState(() {
          if (new_sel.value == last_sel.value) {
            score += new_sel.value;
          } else {
            score += 10;
          }
        });

        last_sel = null;
        undoable = true;
        check_for_win();
      });
    } else {
      //tile exists between selected tiles. Not a valid match
      //behave like no match
      new_sel.focused = true;

      last_sel.state.setState(() {
        last_sel.focused = false;
      });
      last_sel = new_sel;
    }
  } else {
    //no match
    new_sel.focused = true;

    //update last tile
    last_sel.state.setState(() {
      last_sel.focused = false;
    });
    last_sel = new_sel;
  }
}

//also cleans out the bottom row.
void check_for_win() {
  bool cleanup_done = false;
  while (!cleanup_done && tiles.length > 0) {
    if (tiles
            .getRange(tiles.length - 8, tiles.length)
            .where((e) => e.matched)
            .length ==
        8) {
      tiles.removeRange(tiles.length - 8, tiles.length);
    } else {
      cleanup_done = true;
    }
  }

  //board is clear
  if (tiles.length == 0) {
    //save high score and display message
    snack('Contgratulations. You cleared the board with $score');
  }
}

//fill the bottom row with addtional tiles to keep the 8 wide format
void fill_tiles() {
  int fill = -(tiles.length % 8 - 8);
  if (fill != 8) while (fill-- > 0) tiles.add(new Tile());
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

    //load old data if it exists
    _get_data().then((File _file) {
      if (_file.existsSync()) {
        //load file
        _file.readAsString().then((String _data) {
          int count = 0;
          _data.split('\n').forEach((e) {
            if (count == 0)
              score = int.parse(e);
            else if (count == 1)
              move_cost = int.parse(e);
            else if (count == 2)
              high_score = int.parse(e);
            else
              tiles.add(new Tile(value: int.parse(e)));
            count++;
          });
          if (high_score != 0)
            snack('Welcome back, your high score is $high_score.');
          else
            snack('welcome back!');
          setState(() {});
        });
      } else {
        //if no file
        setState(() {
          while (tile_count-- > 0) {
            tiles.add(new Tile(value: rand.nextInt(9) + 1));
          }
        });
      }
    });

    app_state =
        this; //easy reference to the main game state so global setState can be done
  }

  //Put it all together.
  @override
  Widget build(BuildContext context) {
    //fills in the blank spaces with blank cards at the end of the grid
    fill_tiles();

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
          title: new Text(score == 0 ? widget.title : 'Score: ${score}'),
          actions: <Widget>[
            //undo button
            new Opacity(
                child: new IconButton(
                    onPressed: () {
                      setState(() {
                        //move_cost *= 2;
                        if (undoable) {
                          tiles = [];
                          _get_data().then((File _file) {
                            if (_file.existsSync()) {
                              //load file
                              _file.readAsString().then((String _data) {
                                int count = 0;
                                _data.split('\n').forEach((e) {
                                  if (count == 0)
                                    score = int.parse(e);
                                  else if (count == 1)
                                    move_cost = int.parse(e);
                                  else if (count == 2)
                                    high_score = int.parse(e);
                                  else
                                    tiles.add(new Tile(value: int.parse(e)));
                                  count++;
                                });
                                undoable = false;
                                last_sel.state.setState(() {});
                                last_sel = null;
                                setState(() {});
                              });
                            }
                          });
                        }
                      });
                    },
                    tooltip: 'Undo',
                    icon: new Icon(Icons.undo)),
                opacity: undoable ? 1.0 : 0.5),
            //Double up
            new Opacity(
                child: new IconButton(
                    onPressed: () {
                      setState(() {
                        if (score >= move_cost) {
                          save_file((_file) {
                            score -= move_cost;
                            move_cost *= 2;
                            List<Tile> _temp =
                                tiles.where((e) => !e.matched).toList();
                            _temp.forEach(
                                (e) => tiles.add(new Tile(value: e.value)));
                            fill_tiles();
                            make_move_message();
                            app_state.setState(() {}); //okies?
                          });
                        }
                      });
                    },
                    tooltip: 'Double up for $move_cost',
                    icon: new Icon(Icons.add)),
                opacity: score >= move_cost ? 1.0 : 0.5),
            //shuffle button
            new Opacity(
                child: new IconButton(
                    onPressed: () {
                      setState(() {
                        if (score >= move_cost) {
                          save_file((_file) {
                            score -= move_cost;
                            move_cost *= 2;
                            tiles.shuffle();
                            fill_tiles();
                            make_move_message();
                            /*last_sel.state.setState((){
                            last_sel.focused=false;
                          });*/
                            last_sel = null;
                            undoable = false;
                            check_for_win();
                            app_state.setState(() {}); //okies?
                          });
                        }
                      });
                    },
                    tooltip: 'Shuffle for $move_cost',
                    icon: new Icon(Icons.shuffle)),
                opacity: score >= move_cost ? 1.0 : 0.5),
            //restart button
            new IconButton(
                onPressed: () {
                  setState(() {
                    tile_count = 64;
                    score = 0;
                    move_cost = 20;
                    last_sel = null;
                    tiles = [];
                    while (tile_count-- > 0) {
                      tiles.add(new Tile(value: rand.nextInt(9) + 1));
                    }
                  });
                },
                tooltip: 'Restart',
                icon: new Icon(Icons.refresh)),
            //help button
            new IconButton(
                onPressed: () {
                  setState(() {
                    showModalBottomSheet/*<Null>*/(
                        context: context,
                        builder: (BuildContext context) {
                          return new Container(
                              child: new Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: new Text(
                                      '''You will have to match up two matching numbers or two numbers that add up to 10.
The two numbers have to have nothing between them.

You ultimately want to clear all of the board. See if you can.

Using a shuffle or a double up will cost points and will increasingly cost points.
You also cannot undo after using a shuffle.

Good luck.''')));
                        });
                  });
                },
                tooltip: 'Help',
                icon: new Icon(Icons.help_outline))
          ],
          leading: new Image.asset('assets/nuRabbit.png')),
      body: new ScrollableList(children: rows, itemExtent: 60.0),
      /*floatingActionButton: new FloatingActionButton(
        onPressed: () {
          save_file();
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),*/
    );
  }
}

//yay new widget
class Tile extends StatefulWidget {
  Tile({this.value: 0, Key key}) : super(key: key) {
    if (value == 0) matched = true;
  }

  int value;

  bool focused = false;
  bool matched = false;

  State<Tile> state;

  @override
  Tile_state createState() => new Tile_state();
}

class Tile_state extends State<Tile> {
  Color default_color = Colors.white;
  Color focused_color = Colors.cyan[500];

  @override
  void initState() {
    super.initState();
    //value = widget.value; //shorter reference to value
    //default to blank card for filling spaces
  }

  @override
  Widget build(BuildContext context) {
    widget.state = this; //force widget to be aware of state
    return new Card(
        color: widget.focused ? focused_color : default_color,
        child: new InkWell(
            onTap: () {
              setState(() {
                check_tiles(widget);
              });
            },
            child: new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new Opacity(
                    child: new Text('${widget.value}'),
                    opacity: widget.matched ? 0.0 : 1.0))));
  }
}
