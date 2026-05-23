// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutterflip_shared/game_board.dart';
import 'package:flutterflip_shared/move_finder.dart';
import 'package:test/test.dart';

void main() {
  group('ScoredMove', () {
    test('stores score and position correctly', () {
      const scored = ScoredMove(100, Position(1, 2));
      expect(scored.score, equals(100));
      expect(scored.move.x, equals(1));
      expect(scored.move.y, equals(2));
    });
  });

  group('MoveFinder minimax search', () {
    test(
      'findBestMove returns a valid legal starting move for Black at depth 1',
      () {
        final board = GameBoard();
        final bestMove = findBestMove(board, PieceType.black, 1);

        expect(bestMove, isNotNull);
        expect(
          board.isLegalMove(bestMove!.x, bestMove.y, PieceType.black),
          isTrue,
        );
      },
    );

    test(
      'findBestMove returns a valid legal starting move for Black at deeper search depths',
      () {
        final board = GameBoard();
        final bestMove = findBestMove(board, PieceType.black, 3);

        expect(bestMove, isNotNull);
        expect(
          board.isLegalMove(bestMove!.x, bestMove.y, PieceType.black),
          isTrue,
        );
      },
    );

    test('findBestMove returns null if no valid moves exist', () {
      final customRows = List.generate(
        GameBoard.height,
        (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
      );
      // Only Black pieces, no legal moves exist.
      customRows[0][0] = PieceType.black;
      customRows[0][1] = PieceType.black;

      final board = GameBoard.withRows(customRows);
      final bestMove = findBestMove(board, PieceType.black, 3);
      expect(bestMove, isNull);
    });

    test('findBestMove prefers high-value corner positions', () {
      final customRows = List.generate(
        GameBoard.height,
        (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
      );

      // Let's set up a scenario where Black has two legal moves:
      // Move A: Play in a corner (Col 0, Row 0) -> Highly valued at 10000 points.
      // Move B: Play in a normal/worse spot.

      // Row 0: . W B . . . . .
      // Playing at (0, 0) is a corner and flips (1, 0) [White] against (2, 0) [Black].
      // Row 1: B W . . . . . .
      // Playing at (2, 1) is a normal spot and flips (1, 1) [White] against (0, 1) [Black].
      customRows[0][0] = PieceType.empty;
      customRows[0][1] = PieceType.white;
      customRows[0][2] = PieceType.black;

      customRows[1][0] = PieceType.black;
      customRows[1][1] = PieceType.white;
      customRows[1][2] =
          PieceType.empty; // Black playing here is normal move (2, 1)

      final board = GameBoard.withRows(customRows);

      // Verify both moves are legal for Black
      expect(board.isLegalMove(0, 0, PieceType.black), isTrue);
      expect(board.isLegalMove(2, 1, PieceType.black), isTrue);

      // Search at depth 1 to choose the best immediate move
      final bestMove = findBestMove(board, PieceType.black, 1);
      expect(bestMove, isNotNull);
      // Black must prefer the corner move at (0, 0) because of its massive 10000 point score
      expect(bestMove!.x, equals(0));
      expect(bestMove.y, equals(0));
    });
  });
}
