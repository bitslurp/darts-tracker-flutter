import 'package:darts_tracker/model/darts_game.dart';
import 'package:flutter/material.dart';

var numbers = BoardNumber.values.reversed.toList();

class DartsBoardValueInput extends StatefulWidget {
  final ValueSetter<DartsBoardValue> onNextValue;
  DartsBoardValueInput({@required this.onNextValue, key}) : super(key: key);

  @override
  _DartsBoardValueInput createState() => _DartsBoardValueInput(onNextValue);
}

class _DartsBoardValueInput extends State<DartsBoardValueInput> {
  final ValueSetter<DartsBoardValue> onNextValue;
  final List<List<BoardNumber>> numberConfig = [
    numbers.getRange(0, 5).toList(),
    numbers.getRange(5, 10).toList(),
    numbers.getRange(10, 15).toList(),
    numbers.getRange(15, 20).toList()
  ];

  _DartsBoardValueInput(this.onNextValue);

  BoardNumberMultiplier selectedMultiplier = BoardNumberMultiplier.Single;

  void setSelectedMultiplier(BoardNumberMultiplier boardNumberMultiplier) {
    setState(() {
      selectedMultiplier = boardNumberMultiplier;
    });
  }

  List<Widget> _multiplierButtons() {
    return BoardNumberMultiplier.values.map((multiplier) {
      var index = BoardNumberMultiplier.values.indexOf(multiplier);
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
              border: index == 0
                  ? null
                  : Border(left: BorderSide(color: Colors.white, width: 1)),
              color: multiplier == selectedMultiplier
                  ? Colors.grey
                  : Colors.transparent),
          child: FlatButton(
            child: Text(boardMultiplierToString(multiplier)),
            onPressed: () {
              setSelectedMultiplier(multiplier);
            },
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _numberInputs(List<BoardNumber> boardNumbers) {
    return boardNumbers.map((number) {
      var index = boardNumbers.indexOf(number);
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: index == 0
                ? null
                : Border(left: BorderSide(color: Colors.white, width: 1)),
          ),
          child: FlatButton(
            child: Text(boardNumberToValue(number).toString()),
            onPressed: () {
              var dartsthrow =
                  DartsBoardValue.fromBoardNumber(selectedMultiplier, number);
              print(dartsthrow.description);
              onNextValue.call(dartsthrow);
            },
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.white, width: 2))),
          child: Row(
            children: _multiplierButtons(),
          ),
        ),
        ...numberConfig.map((boardNumbers) {
          return Row(children: _numberInputs(boardNumbers));
        })
      ],
    ));
  }
}
