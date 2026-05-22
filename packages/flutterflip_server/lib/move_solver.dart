import 'package:flutterflip_shared/game_board.dart';
import 'package:flutterflip_shared/game_board_scorer.dart';

class ScoredMove {
  final int score;
  final Position move;

  const ScoredMove(this.score, this.move);
}

/// Finds the best next move for [player] on [board] using a minimax search tree to [depth].
Position? findBestMove(GameBoard board, PieceType player, int depth) {
  final bestMove = _performSearchPly(board, player, player, depth - 1);
  return bestMove?.move;
}

ScoredMove? _performSearchPly(
  GameBoard board,
  PieceType scoringPlayer,
  PieceType player,
  int pliesRemaining,
) {
  final availableMoves = board.getMovesForPlayer(player);

  if (availableMoves.isEmpty) {
    return null;
  }

  var score = (scoringPlayer == player) ? minScore : maxScore;
  ScoredMove? bestMove;

  for (var i = 0; i < availableMoves.length; i++) {
    final newBoard = board.updateForMove(
      availableMoves[i].x,
      availableMoves[i].y,
      player,
    );

    if (pliesRemaining > 0 &&
        newBoard.getMovesForPlayer(player.opponent).isNotEmpty) {
      // Opponent has next turn.
      score =
          _performSearchPly(
            newBoard,
            scoringPlayer,
            player.opponent,
            pliesRemaining - 1,
          )?.score ??
          0;
    } else if (pliesRemaining > 0 &&
        newBoard.getMovesForPlayer(player).isNotEmpty) {
      // Opponent has no moves; player gets another turn.
      score =
          _performSearchPly(
            newBoard,
            scoringPlayer,
            player,
            pliesRemaining - 1,
          )?.score ??
          0;
    } else {
      // Search depth reached or game is over.
      score = GameBoardScorer(newBoard).getScore(scoringPlayer);
    }

    if (bestMove == null ||
        (score > bestMove.score && scoringPlayer == player) ||
        (score < bestMove.score && scoringPlayer != player)) {
      bestMove = ScoredMove(
        score,
        Position(availableMoves[i].x, availableMoves[i].y),
      );
    }
  }

  return bestMove;
}
