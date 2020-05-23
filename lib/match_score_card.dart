import 'package:darts_tracker/model/darts_match.dart';
import 'package:flutter/material.dart';

class MatchScoreCard extends StatelessWidget {
  final PlayerMatchScoreCard card;

  MatchScoreCard(this.card);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      padding: EdgeInsets.all(20),
      child: Column(children: [
        Text(card.playerName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            margin: EdgeInsets.only(bottom: 15, top: 5),
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(5)
                // border: Border.all(width: 2.0, color: const Color(0xFF333333))
                ),
            child: Text(
              card.latestGameScoreCard.remainingScore.toString(),
              style: TextStyle(fontSize: 40),
            )),
        Row(
          children: <Widget>[
            Expanded(child: Text("Sets: ${card.setsWon}")),
            Text("Legs: ${card.latestSetLegsWon}")
          ],
        ),
        ...card.latestGameThrows
            .map((throwDescription) => Text(throwDescription))
      ]),
    ));
  }
}
