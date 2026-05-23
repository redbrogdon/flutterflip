// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutterflip_shared/game_board.dart';
import 'package:test/test.dart';

void main() {
  group('PieceType', () {
    test('opponent returns opposite color', () {
      expect(PieceType.black.opponent, equals(PieceType.white));
      expect(PieceType.white.opponent, equals(PieceType.black));
      expect(PieceType.empty.opponent, equals(PieceType.empty));
    });
  });

  group('Position', () {
    test('stores coordinates correctly', () {
      const pos = Position(3, 4);
      expect(pos.x, equals(3));
      expect(pos.y, equals(4));
    });
  });

  group('GameBoard', () {
    test('default constructor initializes standard reversi starting board', () {
      final board = GameBoard();
      // Row 3 (0-indexed): empty, empty, empty, black, white, empty, empty, empty
      expect(board.getPieceAtLocation(3, 3), equals(PieceType.black));
      expect(board.getPieceAtLocation(4, 3), equals(PieceType.white));
      // Row 4 (0-indexed): empty, empty, empty, white, black, empty, empty, empty
      expect(board.getPieceAtLocation(3, 4), equals(PieceType.white));
      expect(board.getPieceAtLocation(4, 4), equals(PieceType.black));

      expect(board.getPieceCount(PieceType.black), equals(2));
      expect(board.getPieceCount(PieceType.white), equals(2));
      expect(board.getPieceCount(PieceType.empty), equals(60));
    });

    test('fromGameBoard copies state correctly', () {
      final original = GameBoard();
      final copy = GameBoard.fromGameBoard(original);
      expect(copy.getPieceAtLocation(3, 3), equals(PieceType.black));
      expect(copy.getPieceCount(PieceType.black), equals(2));

      // Verify immutability: updating original does not affect copy
      final updated = original.updateForMove(2, 4, PieceType.black);
      expect(original.getPieceAtLocation(2, 4), equals(PieceType.empty));
      expect(copy.getPieceAtLocation(2, 4), equals(PieceType.empty));
      expect(updated.getPieceAtLocation(2, 4), equals(PieceType.black));
    });

    test('withRows initializes custom board', () {
      final customRows = List.generate(
        GameBoard.height,
        (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
      );
      customRows[0][0] = PieceType.black;
      customRows[7][7] = PieceType.white;

      final board = GameBoard.withRows(customRows);
      expect(board.getPieceAtLocation(0, 0), equals(PieceType.black));
      expect(board.getPieceAtLocation(7, 7), equals(PieceType.white));
      expect(board.getPieceCount(PieceType.black), equals(1));
      expect(board.getPieceCount(PieceType.white), equals(1));
    });

    test('fromString and toBoardString roundtrips correctly', () {
      final original = GameBoard();
      final str = original.toBoardString();
      expect(str.length, equals(64));

      final parsed = GameBoard.fromString(str);
      expect(parsed.toBoardString(), equals(str));
    });

    test('fromString throws FormatException for invalid strings', () {
      expect(() => GameBoard.fromString('short_string'), throwsFormatException);
      expect(() => GameBoard.fromString('.' * 63 + 'X'), throwsFormatException);
    });

    test('isLegalMove and getMovesForPlayer', () {
      final board = GameBoard();

      // Black should have 4 legal starting moves: (2, 4), (3, 5), (4, 2), (5, 3)
      final blackMoves = board.getMovesForPlayer(PieceType.black);
      expect(blackMoves.length, equals(4));

      final expectedMoves = [
        const Position(2, 4),
        const Position(3, 5),
        const Position(4, 2),
        const Position(5, 3),
      ];

      for (final expected in expectedMoves) {
        expect(
          blackMoves.any((m) => m.x == expected.x && m.y == expected.y),
          isTrue,
        );
        expect(
          board.isLegalMove(expected.x, expected.y, PieceType.black),
          isTrue,
        );
      }

      // Illegal move returns false
      expect(board.isLegalMove(0, 0, PieceType.black), isFalse);
    });

    test('updateForMove executes and flips pieces correctly', () {
      final board = GameBoard();

      // Black plays at (2, 4), which is adjacent to White at (3, 4) and bounded by Black at (4, 4)
      final updated = board.updateForMove(2, 4, PieceType.black);
      expect(updated.getPieceAtLocation(2, 4), equals(PieceType.black));
      expect(
        updated.getPieceAtLocation(3, 4),
        equals(PieceType.black),
      ); // Flipped from White to Black
      expect(
        updated.getPieceAtLocation(4, 4),
        equals(PieceType.black),
      ); // Stays Black
      expect(updated.getPieceCount(PieceType.black), equals(4));
      expect(updated.getPieceCount(PieceType.white), equals(1));
    });
  });
}
