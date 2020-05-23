import 'package:darts_tracker/match_score_card.dart';
import 'package:darts_tracker/model/darts_match.dart';
import 'package:flutter/material.dart';

import 'darts_board_value_input.dart';
import 'model/darts_game.dart';
import 'model/player.dart';

void main() {
  runApp(DartsTrackerApp());
}

class DartsTrackerApp extends StatelessWidget {
  // App Widgest Root
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Darts Tracker',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        accentColor: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.light,
      home: MyHomePage(title: 'Darts Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DartsMatch match =
      DartsMatch(players: [Player("Will", 28), Player("Bob", 28)]);

  void _addThrow(DartsBoardValue throwValue) {
    setState(() {
      match.nextThrow(throwValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    var cards = match.scoreCards;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              ...cards.map(
                (card) => Expanded(child: MatchScoreCard(card)),
              ),
            ]),
          ),
          DartsBoardValueInput(onNextValue: _addThrow),
        ],
      ),
    );
  }
}
