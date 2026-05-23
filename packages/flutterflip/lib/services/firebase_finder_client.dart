import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterflip_shared/game_board.dart';

class FirebaseFinderClient {
  final http.Client _client;
  final String _baseUrl;

  FirebaseFinderClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? const String.fromEnvironment('SERVER_URL');

  /// Queries the Firebase Cloud Function to find the best next move.
  /// Throws a [FormatException] if the input triggers validation errors.
  /// Throws a generic [Exception] if the server returns an error or is unreachable.
  Future<Position?> findNextMove(GameBoard board, PieceType player, int depth) async {
    if (_baseUrl.isEmpty) {
      throw Exception('SERVER_URL environment variable is not defined.');
    }

    final boardStr = board.toBoardString();
    final playerStr = player == PieceType.black ? 'black' : 'white';

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'board': boardStr,
      'player': playerStr,
      'depth': depth.toString(),
    });

    final response = await _client.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return switch (data) {
        {'move': {'x': int x, 'y': int y}} => Position(x, y),
        {'move': null} => null,
        _ => throw const FormatException(
            'Invalid response structure or missing coordinates in success payload.',
          ),
      };
    } else if (response.statusCode == 400) {
      throw FormatException('Validation error from finder: ${response.body}');
    } else {
      throw Exception('Finder backend error (${response.statusCode}): ${response.body}');
    }
  }
}
