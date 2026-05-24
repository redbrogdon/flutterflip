// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'package:firebase_functions/firebase_functions.dart';
import '../bin/server.dart';
import 'package:test/test.dart';

void main() {
  group('GetMove Request Handler Unit Tests', () {
    test('Method guard rejects POST requests with 405', () async {
      final board = '.' * 64;
      final request = Request(
        'POST',
        Uri.parse('http://localhost/getMove?player=black&board=$board'),
      );

      final response = await handleGetMove(request);
      expect(response.statusCode, equals(405));
      final body = await response.readAsString();
      expect(body, equals('Method Not Allowed'));
    });

    test('Missing board parameter returns 400', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/getMove?player=black'),
      );

      final response = await handleGetMove(request);
      expect(response.statusCode, equals(400));
      final body = await response.readAsString();
      expect(body, contains('Invalid or missing "board" parameter'));
    });

    test('Invalid board parameter length returns 400', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/getMove?player=black&board=...'),
      );

      final response = await handleGetMove(request);
      expect(response.statusCode, equals(400));
      final body = await response.readAsString();
      expect(body, contains('Invalid or missing "board" parameter'));
    });

    test('Missing player parameter returns 400', () async {
      final board = '.' * 64;
      final request = Request(
        'GET',
        Uri.parse('http://localhost/getMove?board=$board'),
      );

      final response = await handleGetMove(request);
      expect(response.statusCode, equals(400));
      final body = await response.readAsString();
      expect(body, contains('Invalid or missing "player" parameter'));
    });

    test('Invalid player value returns 400', () async {
      final board = '.' * 64;
      final request = Request(
        'GET',
        Uri.parse('http://localhost/getMove?player=invalid&board=$board'),
      );

      final response = await handleGetMove(request);
      expect(response.statusCode, equals(400));
      final body = await response.readAsString();
      expect(body, contains('Invalid or missing "player" parameter'));
    });

    test('Invalid board character set returns 400', () async {
      final board = '${'.' * 63}X';
      final request = Request(
        'GET',
        Uri.parse('http://localhost/getMove?player=black&board=$board'),
      );

      final response = await handleGetMove(request);
      expect(response.statusCode, equals(400));
      final body = await response.readAsString();
      expect(body, contains('Invalid "board" parameter content'));
    });

    test(
      'Successful GET requests return 200 with best move and correct headers',
      () async {
        // Standard initial Reversi board string
        final boardStr =
            '...........................BW......WB...........................';
        final request = Request(
          'GET',
          Uri.parse(
            'http://localhost/getMove?player=black&depth=3&board=$boardStr',
          ),
        );

        final response = await handleGetMove(request);

        // Assert HTTP status code
        expect(response.statusCode, equals(200));

        // Assert Headers
        expect(response.headers['content-type'], equals('application/json'));
        expect(
          response.headers['cache-control'],
          equals('public, max-age=3600'),
        );

        // Assert Response Body
        final bodyStr = await response.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        expect(body.containsKey('move'), isTrue);
        final move = body['move'] as Map<String, dynamic>?;
        expect(move, isNotNull);
        expect(move!['x'], isA<int>());
        expect(move['y'], isA<int>());
      },
    );

    test(
      'Successful GET requests return move: null when no valid moves exist',
      () async {
        // Board with only black pieces (no moves can be made by either side)
        final boardStr = 'B' * 64;
        final request = Request(
          'GET',
          Uri.parse('http://localhost/getMove?player=black&board=$boardStr'),
        );

        final response = await handleGetMove(request);
        expect(response.statusCode, equals(200));

        final bodyStr = await response.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        expect(body.containsKey('move'), isTrue);
        expect(body['move'], isNull);
      },
    );

    test('Excessive depth parameter is clamped safely', () async {
      final boardStr =
          '...........................BW......WB...........................';
      // Requesting depth 10 (should be clamped to 6 silently and resolve successfully)
      final request = Request(
        'GET',
        Uri.parse(
          'http://localhost/getMove?player=black&depth=10&board=$boardStr',
        ),
      );

      final response = await handleGetMove(request);
      expect(response.statusCode, equals(200));

      final bodyStr = await response.readAsString();
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;
      expect(body['move'], isNotNull);
    });
  });
}
