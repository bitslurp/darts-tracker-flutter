import 'package:darts_tracker/model/player.dart';
import 'package:darts_tracker/model/darts_game.dart';
import 'package:flutter/material.dart';

import 'darts_player_stats.dart';

/// Representation of a darts match for keeping track of match score of over until
/// one of the players won the required amount of sets
class DartsMatch {
  /// When the game was created/started
  DateTime _createdAt;
  final int startingTotal;
  final int setsToWin;
  final int legsToWin;

  List<Player> _players = List();
  List<_DartsMatchSet> _sets = List();
  int _startingPlayerIndex;
  List<_DartsMatchPlayerStats> _dartsMatchScores = List();

  DartsMatch(
      {@required List<Player> players,
      int startingPlayerIndex = 0,
      this.startingTotal = 501,
      this.setsToWin = 3,
      this.legsToWin = 3}) {
    _startingPlayerIndex = startingPlayerIndex;
    _players = players;
    _createdAt = DateTime.now();
    _addSet();
    _setDartsMatchScores();
  }

  _DartsMatchPlayerStats getMatchStatsByPlayerName(String playerName) {
    return _dartsMatchScores
        .firstWhere((stats) => stats.player.name == playerName);
  }

  _DartsSetStats getCurrentSetStatsByPlayerName(String playerName) {
    return _activeSet.setStats
        .firstWhere((stats) => stats.player.name == playerName);
  }

  /// Match is complete when first player wins the required number of sets to win.
  bool get isMatchComplete {
    return _dartsMatchScores.any((score) => score.setsWon == setsToWin);
  }

  nextThrow(DartsBoardValue throwValue) {
    if (isMatchComplete) {
      return;
    }
    final activeGame = _activeGame;
    activeGame.nextThrow(throwValue);

    _setDartsMatchScores();

    if (isMatchComplete) {
      return;
    } else if (_activeSet.isComplete) {
      _addSet();
      _setDartsMatchScores();
    } else if (_activeSet.activeGame.isGameCompleted) {
      _addGameToCurrentSet();
    }
  }

  List<PlayerMatchScoreCard> get scoreCards {
    return _players
        .map((player) => PlayerMatchScoreCard(player, this))
        .toList();
  }

  _DartsMatchSet get _activeSet {
    return _sets.last;
  }

  DartsGame get _activeGame {
    return _activeSet.legs.last;
  }

  void _addSet() {
    _sets.add(_DartsMatchSet());
    _addGameToCurrentSet();
  }

  void _setDartsMatchScores() {
    _sets.forEach((dartsSet) => dartsSet.addStats(_players, legsToWin));

    _dartsMatchScores = _players.map((player) {
      var matchStats = _sets.fold<_DartsMatchPlayerStats>(
          _DartsMatchPlayerStats(player), (stats, dartsSet) {
        var setStats = dartsSet.setStats
            .firstWhere((stats) => stats.player.name == player.name);

        stats.addSetStats(setStats);
        return stats;
      });

      return matchStats;
    }).toList();
  }

  void _addGameToCurrentSet() {
    final playerCount = _players.length;
    final currentSetIndex = _sets.length - 1;
    final setStartingPlayerIndex =
        (currentSetIndex + _startingPlayerIndex) % playerCount;

    final legStartingPlayerIndex =
        (setStartingPlayerIndex + _activeSet.legs.length) % playerCount;

    final game = DartsGame(
        players: _players, startingPlayerIndex: legStartingPlayerIndex);

    _activeSet.legs.add(game);
  }
}

class PlayerMatchScoreCard {
  int setsWon = 0;
  int latestSetLegsWon = 0;
  String playerName;
  DartsPlayerStats matchStats;
  List<String> latestGameThrows = [];
  DartsGameScoreCard latestGameScoreCard;

  PlayerMatchScoreCard(Player player, DartsMatch match) {
    var card = match._dartsMatchScores
        .firstWhere((stats) => stats.player.equals(player));

    setsWon = card.setsWon;
    playerName = card.player.name;
    matchStats = DartsPlayerStats.copy(card);
    latestGameThrows = match._activeGame.turnsByPlayer(player);
    latestGameScoreCard = match._activeGame.scoreCardByPlayer(player);
    latestSetLegsWon = match._activeSet.legsWonByPlayer(player);
  }
}

class _DartsMatchSet {
  List<DartsGame> legs = List();
  List<_DartsSetStats> setStats = List();

  DartsGame get activeGame {
    return legs.last;
  }

  void addStats(List<Player> players, int legsToWin) {
    this.setStats = players.map((player) {
      _DartsSetStats setStats = _DartsSetStats(player);
      legs.forEach((game) {
        setStats.addLegStats(game);
      });

      setStats.legsWon =
          legs.where((game) => game.hasPlayerWon(player.name)).length;
      setStats.hasPlayerWon = setStats.legsWon == legsToWin;

      return setStats;
    }).toList();
  }

  int legsWonByPlayer(Player player) {
    _DartsSetStats stats =
        setStats.firstWhere((stats) => stats.player.equals(player));
    return stats == null ? 0 : stats.legsWon;
  }

  bool get isComplete {
    return setStats.any((stats) => stats.hasPlayerWon);
  }
}

class _DartsMatchPlayerStats extends DartsPlayerStats {
  int setsWon = 0;

  _DartsMatchPlayerStats(Player player) {
    this.player = player;
  }

  void addSetStats(_DartsSetStats _dartsSetStats) {
    addStats(_dartsSetStats);

    if (_dartsSetStats.hasPlayerWon) {
      setsWon++;
    }
  }
}

class _DartsSetStats extends DartsPlayerStats {
  int legsWon;
  bool hasPlayerWon;

  _DartsSetStats(Player player) {
    this.player = player;
  }

  void addLegStats(DartsGame game) {
    var gameStats = game.getStatsByPlayer(player.name);

    addStats(gameStats);
  }
}
