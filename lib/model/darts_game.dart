import 'package:darts_tracker/model/darts_player_stats.dart';
import 'package:darts_tracker/model/player.dart';
import 'package:flutter/material.dart';

/// Use to track scoring and statistics for a single game of darts for n > 0 players.
class DartsGame {
  List<DartsGameScoreCard> _scoreCards = List<DartsGameScoreCard>();

  int _activeScoreCardIndex = 0;
  int _gameStartTotal;

  bool get isGameCompleted =>
      _scoreCards.any((scoreCard) => scoreCard.isScoreReduced);

  DartsGame(
      {@required List<Player> players,
      startingPlayerIndex = 0,
      gameStartTotal = 501}) {
    _activeScoreCardIndex = startingPlayerIndex;
    _gameStartTotal = gameStartTotal;
    _scoreCards = players
        .map<DartsGameScoreCard>(
            (player) => DartsGameScoreCard(player, _gameStartTotal))
        .toList();
  }

  void nextThrow(DartsBoardValue throwValue) {
    if (isGameCompleted) return;

    var scoreCard = activeScoreCard;
    var currentTurn = scoreCard._currentTurn;
    currentTurn._addThrow(throwValue);

    if (_isActivePlayerBust) {
      activeScoreCard._bustTurn();
      _nextTurn();
    } else if (_isActivePlayerScoreReduced) {
      activeScoreCard._addCurrentTurn();
    } else if (currentTurn.turnComplete) {
      activeScoreCard._addCurrentTurn();
      _nextTurn();
    }
  }

  bool hasPlayerWon(String playerName) {
    return _scoreCards
        .firstWhere((card) => card._player.name == playerName)
        .isScoreReduced;
  }

  DartsGamePlayerStats getStatsByPlayer(String playerName) {
    DartsGameScoreCard card =
        _scoreCards.firstWhere((sc) => sc._player.name == playerName);
    final stats = DartsGamePlayerStats();
    stats.player = card._player;
    card._turns.forEach((turn) {
      stats.addTurn(turn.turnThrows, turn.turnTotal);
    });

    stats.hasPlayerWon = card.isScoreReduced;

    return stats;
  }

  void _nextTurn() {
    var nextIndex = _activeScoreCardIndex + 1;
    _activeScoreCardIndex = nextIndex >= _scoreCards.length ? 0 : nextIndex;
  }

  DartsGameScoreCard get activeScoreCard => _scoreCards[_activeScoreCardIndex];

  DartsGameScoreCard scoreCardByPlayer(Player player) {
    return _scoreCards.firstWhere((card) => card._player.equals(player));
  }

  int _calcNextScore() {
    var scoreCard = activeScoreCard;
    return scoreCard.remainingScore - scoreCard._currentTurn.turnTotal;
  }

  List<String> turnsByPlayer(Player player) {
    return _scoreCards
        .firstWhere((card) => player.equals(card._player))
        ._turns
        .map((turn) => turn.description)
        .toList();
  }

  bool get _isActivePlayerScoreReduced {
    var nextScore = _calcNextScore();
    var scoreCard = activeScoreCard;
    return nextScore == 0 && scoreCard._currentTurn._throws.last.isDouble;
  }

  bool get _isActivePlayerBust {
    var nextScore = _calcNextScore();

    return nextScore < 0 ||
        nextScore == 1 ||
        (nextScore == 0 && !_isActivePlayerScoreReduced);
  }
}

int boardNumberToValue(BoardNumber boardNumber) => boardNumber.index + 1;

enum BoardNumber {
  One,
  Two,
  Three,
  Four,
  Five,
  Six,
  Seven,
  Eight,
  Nine,
  Ten,
  Eleven,
  Twelve,
  Thirteen,
  Fourteen,
  Fifteen,
  Sixteen,
  Seventeen,
  Eighteen,
  Nineteen,
  Twenty
}

enum BoardNumberMultiplier { Single, Double, Treble }

String boardMultiplierToString(BoardNumberMultiplier boardNumberMultiplier) {
  switch (boardNumberMultiplier) {
    case BoardNumberMultiplier.Double:
      return "D";
    case BoardNumberMultiplier.Treble:
      return "T";

    default:
      return "S";
  }
}

class DartsBoardValue {
  int _value;
  String _name;

  int get throwValue {
    return _value;
  }

  String get description {
    return _name;
  }

  /// Constructs a [DartsBoardValue] which represents the inner bullseye
  /// position on the dart board with a value of 50
  DartsBoardValue.innerBull() {
    _value = 50;
    _name = "Inner Bull";
  }

  /// Constructs a [DartsBoardValue] which represents the outer bullseye
  /// position on the dart board with a value of 25
  DartsBoardValue.outerBull() {
    _value = 25;
    _name = "Outer Bull";
  }

  DartsBoardValue.miss() {
    _value = 0;
    _name = "Miss";
  }

  DartsBoardValue.fromBoardNumber(
      BoardNumberMultiplier boardNumberMultiplier, BoardNumber boardNumber) {
    _value =
        (boardNumberMultiplier.index + 1) * boardNumberToValue(boardNumber);
    _name =
        '${boardMultiplierToString(boardNumberMultiplier)}${boardNumber.index + 1}';
  }

  bool get isDouble {
    return _name.startsWith("D");
  }
}

class _Turn {
  static final maxThrows = 3;
  List<DartsBoardValue> _throws = List();

  _Turn();

  _Turn.bust() {
    var miss = DartsBoardValue.miss();
    _throws = [miss, miss, miss];
  }

  int get turnTotal {
    return _throws.fold<int>(0, (value, t) => value + t.throwValue);
  }

  int get turnThrows {
    return _throws.length;
  }

  String get description {
    return _throws.map((t) => t.description).join(", ");
  }

  bool get turnComplete {
    return _throws.length == maxThrows;
  }

  void _addThrow(DartsBoardValue throwValue) {
    if (_throws.length < maxThrows) {
      _throws.add(throwValue);
    }
  }

  void _removeThrow() {
    if (_throws.length > 0) {
      _throws.removeLast();
    }
  }
}

/// Score card for a player for an individual darts game.
/// Type not directly visible outside library to hide information/keep interface simpler.
/// All mutative methods are also hidden deliberately.
class DartsGameScoreCard {
  Player _player;
  List<_Turn> _turns = List();
  int _remainingScore = 501;
  _Turn _currentTurn = _Turn();

  DartsGameScoreCard(this._player, this._remainingScore);

  /// Total throws the player has made - excluding the current turn.
  int get throwCount {
    return _turns.map((t) => t.turnThrows).reduce((a, b) => a + b);
  }

  /// Remaining player for player to hit to win game - excluding current turn.
  int get remainingScore {
    return this._remainingScore;
  }

  /// The remaining score adjusted by the current turn.
  int get outstandingScore {
    return remainingScore - _currentTurn.turnTotal;
  }

  /// True if the player has finished the game
  bool get isScoreReduced {
    return remainingScore == 0;
  }

  void _addCurrentTurn() {
    _turns.add(_currentTurn);
    _remainingScore -= _currentTurn.turnTotal;
    _resetCurrentTurn();
  }

  void _bustTurn() {
    _turns.add(_Turn.bust());
    _resetCurrentTurn();
  }

  void _resetCurrentTurn() {
    _currentTurn = _Turn();
  }
}

class DartsGamePlayerStats extends DartsPlayerStats {
  bool hasPlayerWon = false;
}
