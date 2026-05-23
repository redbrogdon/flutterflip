// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutterflip_shared/game_board.dart';
import 'package:flutterflip_shared/game_board_scorer.dart';
import 'package:test/test.dart';

void main() {
  group('GameBoardScorer Constants', () {
    test('maxScore and minScore are correctly balanced', () {
      expect(maxScore, equals(1000000000));
      expect(minScore, equals(-1000000000));
    });
  });

  group('GameBoardScorer Heuristics', () {
    test('symmetric starting board evaluates to zero', () {
      final board = GameBoard();
      final scorer = GameBoardScorer(board);

      expect(scorer.getScore(PieceType.black), equals(0));
      expect(scorer.getScore(PieceType.white), equals(0));
    });

    test(
      'corner placement yields high positive score for player and negative for opponent',
      () {
        final customRows = List.generate(
          GameBoard.height,
          (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
        );

        // Place black in the top-left corner (highly valued)
        customRows[0][0] = PieceType.black;

        // Place white at a bad spot (index 0, 1 is a -1000 square)
        customRows[0][1] = PieceType.white;

        // To prevent this custom board from being marked as "game over", we ensure
        // at least one player has a legal move.
        // Black at (0,0) and White at (0,1) means:
        // Black playing at (0, 2) is a valid move (traps white at 0,1).
        final board = GameBoard.withRows(customRows);
        final scorer = GameBoardScorer(board);

        // Score for Black should be: 10000 (corner) - (-1000) (white at 0,1) = 11000
        expect(scorer.getScore(PieceType.black), equals(11000));
        // Score for White should be: -1000 (bad spot) - 10000 (black at 0,0) = -11000
        expect(scorer.getScore(PieceType.white), equals(-11000));
      },
    );
  });

  group('GameBoardScorer Game Over Rules', () {
    test('winning game over state (only black pieces) returns maxScore', () {
      final customRows = List.generate(
        GameBoard.height,
        (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
      );
      // Only Black pieces exist. No legal moves are possible for either side.
      customRows[0][0] = PieceType.black;
      customRows[0][1] = PieceType.black;

      final board = GameBoard.withRows(customRows);
      final scorer = GameBoardScorer(board);

      expect(scorer.getScore(PieceType.black), equals(maxScore));
    });

    test('losing game over state (only white pieces) returns minScore', () {
      final customRows = List.generate(
        GameBoard.height,
        (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
      );
      // Only White pieces exist. No legal moves are possible for either side.
      customRows[0][0] = PieceType.white;
      customRows[0][1] = PieceType.white;

      final board = GameBoard.withRows(customRows);
      final scorer = GameBoardScorer(board);

      expect(scorer.getScore(PieceType.black), equals(minScore));
    });

    test('tied game over state (completely empty board) returns zero', () {
      final customRows = List.generate(
        GameBoard.height,
        (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
      );
      // No pieces exist on the board.
      final board = GameBoard.withRows(customRows);
      final scorer = GameBoardScorer(board);

      expect(scorer.getScore(PieceType.black), equals(0));
    });
  });
}
