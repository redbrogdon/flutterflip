import 'dart:convert';
import 'dart:math' as math;
import 'package:firebase_functions/firebase_functions.dart';
import 'package:flutterflip_shared/game_board.dart';
import 'package:flutterflip_server/move_solver.dart';

void main(List<String> args) {
  fireUp(args, (Firebase firebase) {
    // Solve/Find Move Endpoint
    firebase.https.onRequest(name: 'getMove', (Request request) async {
      if (request.method != 'GET') {
        return Response(405, body: 'Method Not Allowed');
      }

      try {
        final params = request.requestedUri.queryParameters;
        final boardStr = params['board'];
        final playerStr = params['player'];
        final requestedDepth = int.tryParse(params['depth'] ?? '') ?? 4;

        if (boardStr == null || boardStr.length != 64) {
          return Response(
            400,
            body:
                'Invalid or missing "board" parameter. Must be exactly 64 characters.',
          );
        }

        final player = switch (playerStr?.toLowerCase()) {
          'black' => PieceType.black,
          'white' => PieceType.white,
          _ => null,
        };

        if (player == null) {
          return Response(
            400,
            body:
                'Invalid or missing "player" parameter. Must be "black" or "white".',
          );
        }

        // Security & Timeout Defense: Clamp depth to a safe, robust range (1 to 6)
        final depth = math.max(1, math.min(requestedDepth, 6));

        final board = GameBoard.fromString(boardStr);
        final bestMove = findBestMove(board, player, depth);

        return Response.ok(
          jsonEncode({
            'player': playerStr,
            'move': bestMove != null
                ? {'x': bestMove.x, 'y': bestMove.y}
                : null,
            'depth': depth,
          }),
          headers: {
            'content-type': 'application/json',
            'cache-control': 'public, max-age=3600', // Cacheable for 1 hour
          },
        );
      } catch (e) {
        return Response(500, body: 'Error processing request: $e');
      }
    });
  });
}
