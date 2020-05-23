import 'package:darts_tracker/model/darts_game.dart';
import 'package:darts_tracker/model/player.dart';
import 'package:darts_tracker/model/darts_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var treble20 = DartsBoardValue.fromBoardNumber(
      BoardNumberMultiplier.Treble, BoardNumber.Twenty);

  DartsMatch dartsMatch;
  void throwOneEighty() {
    dartsMatch.nextThrow(treble20);
    dartsMatch.nextThrow(treble20);
    dartsMatch.nextThrow(treble20);
  }

  void throwMiss() {
    var miss = DartsBoardValue.miss();
    dartsMatch.nextThrow(miss);
    dartsMatch.nextThrow(miss);
    dartsMatch.nextThrow(miss);
  }

  void throwDTwelve141() {
    dartsMatch.nextThrow(treble20);
    dartsMatch.nextThrow(DartsBoardValue.fromBoardNumber(
        BoardNumberMultiplier.Treble, BoardNumber.Nineteen));
    dartsMatch.nextThrow(DartsBoardValue.fromBoardNumber(
        BoardNumberMultiplier.Double, BoardNumber.Twelve));
  }

  group("Single Player Match Tests", () {
    setUp(() {
      dartsMatch =
          DartsMatch(players: [Player("Will", 28)], setsToWin: 1, legsToWin: 2);
    });

    void hit9Darter() {
      throwOneEighty();
      throwOneEighty();
      throwDTwelve141();
    }

    test('match should not be complete', () {
      expect(dartsMatch.isMatchComplete, isFalse);
    });

    test("Single go should not break anything", () {
      throwOneEighty();

      expect(dartsMatch.isMatchComplete, isFalse);
    });

    test("Single turn should finish first leg", () {
      hit9Darter();

      var stats = dartsMatch.getCurrentSetStatsByPlayerName("Will");

      expect(stats.legsWon, equals(1));
      expect(dartsMatch.isMatchComplete, isFalse);
    });

    test("Double turn should finish match", () {
      hit9Darter();
      hit9Darter();

      var stats = dartsMatch.getCurrentSetStatsByPlayerName("Will");

      expect(stats.legsWon, equals(2));
      expect(dartsMatch.isMatchComplete, isTrue);
    });
  });

  group("Two Player Match Tests - 1 Set first to two legs", () {
    setUp(() {
      dartsMatch = DartsMatch(
          players: [Player("Will", 28), Player("Bob", 28)],
          setsToWin: 1,
          legsToWin: 2);
    });

    void hit9Darter() {
      throwOneEighty();
      throwMiss();
      throwOneEighty();
      throwMiss();
      throwDTwelve141();
    }

    test("Double 9 darter should have score at 1 leg a piece", () {
      hit9Darter();
      hit9Darter();

      var scoreCards = dartsMatch.scoreCards;

      var willStats = scoreCards.firstWhere((c) => c.playerName == "Will");
      var bobStats = scoreCards.firstWhere((c) => c.playerName == "Bob");

      expect(willStats.latestSetLegsWon, equals(1));
      expect(bobStats.latestSetLegsWon, equals(1));
      expect(dartsMatch.isMatchComplete, isFalse);
    });

    test("Treble 9 darter should have Will win match", () {
      hit9Darter();
      hit9Darter();
      hit9Darter();

      var scoreCards = dartsMatch.scoreCards;

      var willStats = scoreCards.firstWhere((c) => c.playerName == "Will");
      var bobStats = scoreCards.firstWhere((c) => c.playerName == "Bob");

      expect(willStats.latestSetLegsWon, equals(2));
      expect(bobStats.latestSetLegsWon, equals(1));
      expect(willStats.setsWon, equals(1));
      expect(bobStats.setsWon, equals(0));
      expect(dartsMatch.isMatchComplete, isTrue);
    });
  });

  group("Two Player Match Tests - 2 Sets first to 3 legs", () {
    setUp(() {
      dartsMatch = DartsMatch(
          players: [Player("Will", 28), Player("Bob", 28)],
          setsToWin: 2,
          legsToWin: 3);
    });

    void hit9DarterP1() {
      throwOneEighty();
      throwMiss();
      throwOneEighty();
      throwMiss();
      throwDTwelve141();
    }

    void hit9DarterP2() {
      throwMiss();
      throwOneEighty();
      throwMiss();
      throwOneEighty();
      throwMiss();
      throwDTwelve141();
    }

    test("Two Player - First to 2 sets - should start set two with Bob", () {
      hit9DarterP1();
      hit9DarterP2();
      hit9DarterP2();
      hit9DarterP1();
      hit9DarterP2();

      // Set two should begin with bob
      hit9DarterP1();

      var scoreCards = dartsMatch.scoreCards;
      var willStats = scoreCards.firstWhere((c) => c.playerName == "Will");
      var bobStats = scoreCards.firstWhere((c) => c.playerName == "Bob");

      expect(willStats.setsWon, equals(0));
      expect(bobStats.setsWon, equals(1));
      expect(bobStats.latestSetLegsWon, equals(1));
      expect(willStats.latestSetLegsWon, equals(0));
    });
  });
}
