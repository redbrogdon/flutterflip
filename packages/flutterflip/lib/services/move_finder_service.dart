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
      final move = await _remoteClient.findNextMove(board, player, depth);
      return move;
    } catch (_) {
      return _localClient.findNextMove(board, player, depth);
    }
  }
}
