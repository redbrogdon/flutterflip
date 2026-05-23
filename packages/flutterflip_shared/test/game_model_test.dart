// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutterflip_shared/game_board.dart';
import 'package:flutterflip_shared/game_model.dart';
import 'package:test/test.dart';

void main() {
  group('GameModel Initialization', () {
    test('default player is PieceType.black', () {
      final model = GameModel(board: GameBoard());
      expect(model.player, equals(PieceType.black));
      expect(model.blackScore, equals(2));
      expect(model.whiteScore, equals(2));
      expect(model.gameIsOver, isFalse);
    });

    test('custom player can be specified', () {
      final model = GameModel(board: GameBoard(), player: PieceType.white);
      expect(model.player, equals(PieceType.white));
    });
  });

  group('GameModel Scores & Outcomes', () {
    test('gameResultString returns correctly based on score - Black wins', () {
      final customRows = List.generate(
        GameBoard.height,
        (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
      );
      customRows[0][0] = PieceType.black;
      customRows[0][1] = PieceType.black;
      customRows[0][2] = PieceType.white;

      final model = GameModel(board: GameBoard.withRows(customRows));
      expect(model.blackScore, equals(2));
      expect(model.whiteScore, equals(1));
      expect(model.gameResultString, equals('Black wins.'));
    });

    test('gameResultString returns correctly based on score - White wins', () {
      final customRows = List.generate(
        GameBoard.height,
        (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
      );
      customRows[0][0] = PieceType.black;
      customRows[0][1] = PieceType.white;
      customRows[0][2] = PieceType.white;

      final model = GameModel(board: GameBoard.withRows(customRows));
      expect(model.blackScore, equals(1));
      expect(model.whiteScore, equals(2));
      expect(model.gameResultString, equals('White wins.'));
    });

    test('gameResultString returns correctly based on score - Tie', () {
      final customRows = List.generate(
        GameBoard.height,
        (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
      );
      customRows[0][0] = PieceType.black;
      customRows[0][1] = PieceType.white;

      final model = GameModel(board: GameBoard.withRows(customRows));
      expect(model.blackScore, equals(1));
      expect(model.whiteScore, equals(1));
      expect(model.gameResultString, equals('Tie.'));
    });
  });

  group('GameModel Turns & State Transitions', () {
    test('updateForMove throws exception for illegal moves', () {
      final model = GameModel(board: GameBoard());
      expect(() => model.updateForMove(0, 0), throwsException);
    });

    test(
      'updateForMove updates board and alternates turn to opponent when legal moves exist',
      () {
        final model = GameModel(board: GameBoard(), player: PieceType.black);

        // Black plays legal move at (2, 4)
        final nextModel = model.updateForMove(2, 4);
        expect(
          nextModel.board.getPieceAtLocation(2, 4),
          equals(PieceType.black),
        );
        // White should have moves, so it should alternate to White
        expect(nextModel.player, equals(PieceType.white));
      },
    );

    test(
      'updateForMove skips opponent turn when opponent has no valid moves but current player does',
      () {
        final customRows = List.generate(
          GameBoard.height,
          (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
        );

        // Row 4: Black Col 0-4, White Col 5, Col 6-7 empty
        customRows[4][0] = PieceType.black;
        customRows[4][1] = PieceType.black;
        customRows[4][2] = PieceType.black;
        customRows[4][3] = PieceType.black;
        customRows[4][4] = PieceType.black;
        customRows[4][5] = PieceType.white;

        // Row 1: Black Col 0, White Col 1, Col 2 empty
        customRows[1][0] = PieceType.black;
        customRows[1][1] = PieceType.white;

        // Add another White piece that is completely isolated at (7, 7)
        customRows[7][7] = PieceType.white;

        final board = GameBoard.withRows(customRows);
        final model = GameModel(board: board, player: PieceType.black);

        // Verify Black can play at (2, 1)
        expect(model.board.isLegalMove(2, 1, PieceType.black), isTrue);
        // Verify Black can play at (6, 4)
        expect(model.board.isLegalMove(6, 4, PieceType.black), isTrue);

        // Verify White has 0 legal moves on the starting board
        expect(model.board.getMovesForPlayer(PieceType.white).isEmpty, isTrue);

        // Black plays at (2, 1), which flips (1, 1) to Black.
        // White at (5, 4) and (7, 7) remain on the board (game is not over).
        // White still has 0 legal moves.
        // Black still has a move at (6, 4).
        final nextModel = model.updateForMove(2, 1);
        expect(
          nextModel.board.getPieceAtLocation(2, 1),
          equals(PieceType.black),
        );
        expect(
          nextModel.board.getPieceAtLocation(1, 1),
          equals(PieceType.black),
        ); // Flipped
        expect(
          nextModel.player,
          equals(PieceType.black),
        ); // Turn skips White and remains Black!
      },
    );

    test(
      'updateForMove sets active player to PieceType.empty when no moves remain for either',
      () {
        final customRows = List.generate(
          GameBoard.height,
          (y) => List.generate(GameBoard.width, (x) => PieceType.empty),
        );
        customRows[0][0] = PieceType.black;
        customRows[0][1] = PieceType.white;

        final model = GameModel(
          board: GameBoard.withRows(customRows),
          player: PieceType.black,
        );
        // Black plays at (2, 0), flips (1, 0) to Black. Now board is completely Black.
        final nextModel = model.updateForMove(2, 0);
        expect(
          nextModel.board.getPieceAtLocation(1, 0),
          equals(PieceType.black),
        ); // Flipped
        expect(
          nextModel.player,
          equals(PieceType.empty),
        ); // No moves left for either, so empty
        expect(nextModel.gameIsOver, isTrue);
      },
    );
  });
}
