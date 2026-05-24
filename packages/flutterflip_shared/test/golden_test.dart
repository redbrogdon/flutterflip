// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'package:flutterflip_shared/game_board.dart';
import 'package:flutterflip_shared/game_board_scorer.dart';
import 'package:flutterflip_shared/move_finder.dart';
import 'package:test/test.dart';

void main() {
  group('Golden Board Tests', () {
    // Load generated test cases JSON
    final jsonStr = File('test/test_cases.json').readAsStringSync();
    final testCases = jsonDecode(jsonStr) as List<dynamic>;

    for (final testCase in testCases) {
      final name = testCase['name'] as String;
      final boardStr = testCase['board'] as String;

      group('Board Setup: $name', () {
        late GameBoard board;
        late GameBoardScorer scorer;

        setUp(() {
          board = GameBoard.fromString(boardStr);
          scorer = GameBoardScorer(board);
        });

        test('Piece counts match expected values', () {
          expect(
            board.getPieceCount(PieceType.black),
            equals(testCase['blackPieceCount']),
          );
          expect(
            board.getPieceCount(PieceType.white),
            equals(testCase['whitePieceCount']),
          );
        });

        test('GameBoardScorer scores match expected values', () {
          expect(
            scorer.getScore(PieceType.black),
            equals(testCase['blackScore']),
          );
          expect(
            scorer.getScore(PieceType.white),
            equals(testCase['whiteScore']),
          );
        });

        test('Black available moves match expected list', () {
          final expectedList =
              (testCase['blackAvailableMoves'] as List<dynamic>)
                  .map((m) => Position(m['x'] as int, m['y'] as int))
                  .toList();
          final actualList = board.getMovesForPlayer(PieceType.black);

          expect(actualList.length, equals(expectedList.length));
          for (final expected in expectedList) {
            expect(
              actualList.any((p) => p.x == expected.x && p.y == expected.y),
              isTrue,
              reason: 'Missing expected move (${expected.x}, ${expected.y})',
            );
          }
        });

        test('White available moves match expected list', () {
          final expectedList =
              (testCase['whiteAvailableMoves'] as List<dynamic>)
                  .map((m) => Position(m['x'] as int, m['y'] as int))
                  .toList();
          final actualList = board.getMovesForPlayer(PieceType.white);

          expect(actualList.length, equals(expectedList.length));
          for (final expected in expectedList) {
            expect(
              actualList.any((p) => p.x == expected.x && p.y == expected.y),
              isTrue,
              reason: 'Missing expected move (${expected.x}, ${expected.y})',
            );
          }
        });

        test('Black best move at Depth 1 matches expected decision', () {
          final bestMove = findBestMove(board, PieceType.black, 1);
          final expectedMove = testCase['blackBestMoveDepth1'];
          if (expectedMove == null) {
            expect(bestMove, isNull);
          } else {
            expect(bestMove, isNotNull);
            expect(bestMove!.x, equals(expectedMove['x']));
            expect(bestMove.y, equals(expectedMove['y']));
          }
        });

        test('Black best move at Depth 3 matches expected decision', () {
          final bestMove = findBestMove(board, PieceType.black, 3);
          final expectedMove = testCase['blackBestMoveDepth3'];
          if (expectedMove == null) {
            expect(bestMove, isNull);
          } else {
            expect(bestMove, isNotNull);
            expect(bestMove!.x, equals(expectedMove['x']));
            expect(bestMove.y, equals(expectedMove['y']));
          }
        });

        test('Black best move at Depth 5 matches expected decision', () {
          final bestMove = findBestMove(board, PieceType.black, 5);
          final expectedMove = testCase['blackBestMoveDepth5'];
          if (expectedMove == null) {
            expect(bestMove, isNull);
          } else {
            expect(bestMove, isNotNull);
            expect(bestMove!.x, equals(expectedMove['x']));
            expect(bestMove.y, equals(expectedMove['y']));
          }
        });

        test('White best move at Depth 1 matches expected decision', () {
          final bestMove = findBestMove(board, PieceType.white, 1);
          final expectedMove = testCase['whiteBestMoveDepth1'];
          if (expectedMove == null) {
            expect(bestMove, isNull);
          } else {
            expect(bestMove, isNotNull);
            expect(bestMove!.x, equals(expectedMove['x']));
            expect(bestMove.y, equals(expectedMove['y']));
          }
        });

        test('White best move at Depth 3 matches expected decision', () {
          final bestMove = findBestMove(board, PieceType.white, 3);
          final expectedMove = testCase['whiteBestMoveDepth3'];
          if (expectedMove == null) {
            expect(bestMove, isNull);
          } else {
            expect(bestMove, isNotNull);
            expect(bestMove!.x, equals(expectedMove['x']));
            expect(bestMove.y, equals(expectedMove['y']));
          }
        });

        test('White best move at Depth 5 matches expected decision', () {
          final bestMove = findBestMove(board, PieceType.white, 5);
          final expectedMove = testCase['whiteBestMoveDepth5'];
          if (expectedMove == null) {
            expect(bestMove, isNull);
          } else {
            expect(bestMove, isNotNull);
            expect(bestMove!.x, equals(expectedMove['x']));
            expect(bestMove.y, equals(expectedMove['y']));
          }
        });
      });
    }
  });
}
