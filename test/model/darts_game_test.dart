import 'package:darts_tracker/model/player.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darts_tracker/model/darts_game.dart';

void main() {
  var treble20 = DartsBoardValue.fromBoardNumber(
      BoardNumberMultiplier.Treble, BoardNumber.Twenty);
  group("Single Player Game Tests", () {
    DartsGame dartsGame;
    void throwOneEighty() {
      dartsGame.nextThrow(treble20);
      dartsGame.nextThrow(treble20);
      dartsGame.nextThrow(treble20);
    }

    void throwDTwelve141() {
      dartsGame.nextThrow(treble20);
      dartsGame.nextThrow(DartsBoardValue.fromBoardNumber(
          BoardNumberMultiplier.Treble, BoardNumber.Nineteen));
      dartsGame.nextThrow(DartsBoardValue.fromBoardNumber(
          BoardNumberMultiplier.Double, BoardNumber.Twelve));
    }

    setUp(() {
      dartsGame = DartsGame(players: [Player("Will", 28)]);
    });
    test('Game creation', () {
      expect(dartsGame.isGameCompleted, isFalse);
    });

    test("Single Throw", () {
      dartsGame.nextThrow(DartsBoardValue.fromBoardNumber(
          BoardNumberMultiplier.Treble, BoardNumber.Twenty));

      expect(dartsGame.activeScoreCard.outstandingScore, equals(441));
      expect(dartsGame.activeScoreCard.remainingScore, equals(501));
    });

    test("One Turn adjusts score correctly", () {
      throwOneEighty();

      expect(dartsGame.activeScoreCard.outstandingScore, equals(321));
      expect(dartsGame.activeScoreCard.remainingScore, equals(321));
    });

    test("Nine darter - D12 finish", () {
      throwOneEighty();
      throwOneEighty();
      throwDTwelve141();

      expect(dartsGame.activeScoreCard.outstandingScore, equals(0));
      expect(dartsGame.activeScoreCard.remainingScore, equals(0));
      expect(dartsGame.isGameCompleted, isTrue);
      expect(dartsGame.activeScoreCard.throwCount, equals(9));
    });

    test("Nine darts to bust", () {
      throwOneEighty();
      throwOneEighty();
      throwOneEighty();
      final scoreCard = dartsGame.activeScoreCard;
      expect(scoreCard.outstandingScore, equals(141));
      expect(scoreCard.remainingScore, equals(141));
      expect(dartsGame.isGameCompleted, isFalse);
      expect(scoreCard.throwCount, equals(9));
    });
  });
}
