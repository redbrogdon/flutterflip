import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutterflip_shared/game_board.dart';
import 'package:flutterflip_shared/move_finder.dart';

class LocalSearchArgs {
  final GameBoard board;
  final PieceType player;
  final int depth;

  LocalSearchArgs({
    required this.board,
    required this.player,
    required this.depth,
  });
}

Position? _findNextMove(LocalSearchArgs args) {
  return findBestMove(args.board, args.player, args.depth);
}

class LocalFinderClient {
  /// Resolves the optimal next move locally using a background CPU isolate.
  Future<Position?> findNextMove(GameBoard board, PieceType player, int depth) {
    return compute(
      _findNextMove,
      LocalSearchArgs(board: board, player: player, depth: depth),
    );
  }
}
