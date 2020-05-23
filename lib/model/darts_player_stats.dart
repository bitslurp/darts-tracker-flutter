import 'package:darts_tracker/model/player.dart';

/// Utility class to track generic statistics for a darts player
class DartsPlayerStats {
  Player player;
  int oneEighties = 0;
  int oneFourties = 0;
  int tons = 0;
  double oneDartAvg = 0;
  double threeDartAvg = 0;
  int throws = 0;
  int total = 0;

  DartsPlayerStats() {}

  DartsPlayerStats.copy(DartsPlayerStats other) {
    player = other.player;
    oneEighties = other.oneEighties;
    oneFourties = other.oneFourties;
    tons = other.tons;
    oneDartAvg = other.oneDartAvg;
    threeDartAvg = other.threeDartAvg;
    throws = other.throws;
    total = other.total;
  }

  /// Add a turn to current stats. The method will use the [turnTotal] to track high scores (180s etc.) and will also
  /// accumulate the overall totals to update the throwing averages.
  /// ```
  /// stats.addTurn(3, 150);
  /// // increments the total 140s by 1 and adjusts the player averages
  /// ```
  ///
  void addTurn(int turnThrows, int turnTotal) {
    throws += turnThrows;
    total += turnTotal;
    _setDartAverges();
    if (turnTotal == 180) {
      oneEighties++;
    } else if (turnTotal > 139) {
      oneFourties++;
    } else if (turnTotal > 99) {
      tons++;
    }
  }

  /// Set dart averages based upon current total & and number of throws.
  void _setDartAverges() {
    oneDartAvg = throws > 0 ? total / throws : 0;
    threeDartAvg = oneDartAvg * 3;
  }

  /// Adds the [other] set of darts player statistics to the current values and updates the overall averages.
  void addStats(DartsPlayerStats other) {
    oneFourties += other.oneFourties;
    oneEighties += other.oneEighties;
    tons += other.tons;
    total += other.total;
    throws += other.throws;
    _setDartAverges();
  }
}
