import 'dart:convert';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:flutterflip_shared/game_board.dart';
import 'package:flutterflip_shared/move_finder.dart';

void main(List<String> args) {
  fireUp(args, (Firebase firebase) {
    // Find Move Endpoint
    firebase.https.onRequest(
      name: 'getMove',
      handleGetMove,
      options: const HttpsOptions(
        cors: Cors(['https://flutterflip.web.app', 'https://redbrogdon.dev']),
      ),
    );
  });
}

Future<Response> handleGetMove(Request request) async {
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
    final depth = requestedDepth.clamp(1, 6);

    final board = GameBoard.fromString(boardStr);
    final bestMove = findBestMove(board, player, depth);

    return Response.ok(
      jsonEncode({
        'move': bestMove != null ? {'x': bestMove.x, 'y': bestMove.y} : null,
      }),
      headers: {
        'content-type': 'application/json',
        'cache-control': 'public, max-age=3600', // Cacheable for 1 hour
      },
    );
  } on FormatException catch (e) {
    return Response(
      400,
      body: 'Invalid "board" parameter content: ${e.message}',
    );
  } catch (e) {
    return Response(500, body: 'Error processing request: $e');
  }
}
