// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'package:flutterflip_shared/game_board.dart';
import 'package:flutterflip_shared/game_board_scorer.dart';
import 'package:flutterflip_shared/move_finder.dart';

class RawBoardConfig {
  final String name;
  final String boardStr;

  RawBoardConfig(this.name, this.boardStr);
}

void main() {
  final rawConfigs = [
    RawBoardConfig(
      'Initial Board',
      '........'
          '........'
          '........'
          '...BW...'
          '...WB...'
          '........'
          '........'
          '........',
    ),
    RawBoardConfig(
      'Corner Play Opportunity',
      '........'
          '........'
          '........'
          '.W......'
          '..B.....'
          '........'
          '........'
          '........',
    ),
    RawBoardConfig(
      'Blocked Opponent (White has no legal moves)',
      'BBBBBBBB'
          'BW......'
          '........'
          '........'
          'BBBBBW..'
          '........'
          '........'
          '.......W',
    ),
    RawBoardConfig(
      'Completed Match (All Black)',
      'BBBBBBBB'
          'BBBBBBBB'
          'BBBBBBBB'
          'BBBBBBBB'
          'BBBBBBBB'
          'BBBBBBBB'
          'BBBBBBBB'
          'BBBBBBBB',
    ),
    RawBoardConfig(
      'One Empty Square (Either Player Can Play)',
      'BBBBBBBB'
          'BBBBBBBB'
          'BBBBBBBB'
          'BBBBBBBB'
          'BBBBBBBB'
          'BBBBBBBB'
          'BBBBBBWB'
          'BBBBBWB.',
    ),
    RawBoardConfig(
      'Completely Empty Board',
      '........'
          '........'
          '........'
          '........'
          '........'
          '........'
          '........'
          '........',
    ),
  ];

  final testCases = <Map<String, dynamic>>[];

  for (final config in rawConfigs) {
    final board = GameBoard.fromString(config.boardStr);
    final scorer = GameBoardScorer(board);

    // Compute piece counts
    final blackPieces = board.getPieceCount(PieceType.black);
    final whitePieces = board.getPieceCount(PieceType.white);

    // Compute available moves
    final blackAvailable = board
        .getMovesForPlayer(PieceType.black)
        .map((p) => {'x': p.x, 'y': p.y})
        .toList();
    final whiteAvailable = board
        .getMovesForPlayer(PieceType.white)
        .map((p) => {'x': p.x, 'y': p.y})
        .toList();

    // Compute scores
    final blackScore = scorer.getScore(PieceType.black);
    final whiteScore = scorer.getScore(PieceType.white);

    // Compute best moves at depths 1, 3, and 5
    final blackBestMoveDepth1 = findBestMove(board, PieceType.black, 1);
    final blackBestMoveDepth3 = findBestMove(board, PieceType.black, 3);
    final blackBestMoveDepth5 = findBestMove(board, PieceType.black, 5);

    final whiteBestMoveDepth1 = findBestMove(board, PieceType.white, 1);
    final whiteBestMoveDepth3 = findBestMove(board, PieceType.white, 3);
    final whiteBestMoveDepth5 = findBestMove(board, PieceType.white, 5);

    testCases.add({
      'name': config.name,
      'board': config.boardStr,
      'blackPieceCount': blackPieces,
      'whitePieceCount': whitePieces,
      'blackScore': blackScore,
      'whiteScore': whiteScore,
      'blackAvailableMoves': blackAvailable,
      'whiteAvailableMoves': whiteAvailable,
      'blackBestMoveDepth1': blackBestMoveDepth1 != null
          ? {'x': blackBestMoveDepth1.x, 'y': blackBestMoveDepth1.y}
          : null,
      'blackBestMoveDepth3': blackBestMoveDepth3 != null
          ? {'x': blackBestMoveDepth3.x, 'y': blackBestMoveDepth3.y}
          : null,
      'blackBestMoveDepth5': blackBestMoveDepth5 != null
          ? {'x': blackBestMoveDepth5.x, 'y': blackBestMoveDepth5.y}
          : null,
      'whiteBestMoveDepth1': whiteBestMoveDepth1 != null
          ? {'x': whiteBestMoveDepth1.x, 'y': whiteBestMoveDepth1.y}
          : null,
      'whiteBestMoveDepth3': whiteBestMoveDepth3 != null
          ? {'x': whiteBestMoveDepth3.x, 'y': whiteBestMoveDepth3.y}
          : null,
      'whiteBestMoveDepth5': whiteBestMoveDepth5 != null
          ? {'x': whiteBestMoveDepth5.x, 'y': whiteBestMoveDepth5.y}
          : null,
    });
  }

  final encoder = const JsonEncoder.withIndent('  ');
  final jsonString = encoder.convert(testCases);

  // Write the file into packages/flutterflip_shared/test/test_cases.json
  // We determine path relative to packages/flutterflip_shared
  final outputFile = File('test/test_cases.json');
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(jsonString);

  // ignore: avoid_print
  print(
    'Successfully generated test_cases.json with ${testCases.length} sample boards!',
  );
}
