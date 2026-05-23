import 'dart:developer' as developer;
import 'package:flutterflip_shared/game_board.dart';
import 'firebase_finder_client.dart';
import 'local_finder_client.dart';

class MoveFinderService {
  final FirebaseFinderClient _remoteClient;
  final LocalFinderClient _localClient;

  MoveFinderService({
    FirebaseFinderClient? remoteClient,
    LocalFinderClient? localClient,
  }) : _remoteClient = remoteClient ?? FirebaseFinderClient(),
       _localClient = localClient ?? LocalFinderClient();

  /// Finds the optimal next Reversi move. Attempts to hit the Firebase server first
  /// and falls back dynamically to the local CPU isolate finder if offline or a network error occurs.
  Future<Position?> findNextMove(
    GameBoard board,
    PieceType player,
    int depth,
  ) async {
    try {
      developer.log(
        'Attempting to fetch move from remote finder...',
        name: 'MoveFinderService',
      );
      final move = await _remoteClient.findNextMove(board, player, depth);
      developer.log(
        'Successfully retrieved move from remote finder: ${move != null ? "(${move.x}, ${move.y})" : "PASS"}',
        name: 'MoveFinderService',
      );
      return move;
    } catch (e, stack) {
      developer.log(
        'Remote finder failed/unreachable. Falling back to local isolate finder. Error: $e',
        name: 'MoveFinderService',
        error: e,
        stackTrace: stack,
      );
      return _localClient.findNextMove(board, player, depth);
    }
  }
}
