// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'package:flutterflip_shared/game_board.dart';

/// The Theme class is part of Flutter's Material Design package, which this
/// game doesn't use. Instead, this static class is used as a convenient spot to
/// hold constants for colors, text styles, and so on.
abstract class Styling {
  // **** GRADIENTS AND COLORS ****

  static const oldGoldColor = Color(0xffb89730); // Burnished old gold
  static const brownColor = Color(0xff2b140b); // Mahogany dark brown
  static const backgroundStartColor = Color(
    0xff0d2e13,
  ); // Deep British Racing Green felt
  static const backgroundFinishColor = Color(
    0xff051406,
  ); // Darkest shadow green
  static const thinkingColor = Color(0xa0ffffff);

  static const Map<PieceType, LinearGradient> pieceGradients = {
    PieceType.black: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xff0a0a0a), Color(0xff242424)], // Ebony / obsidian
    ),
    PieceType.white: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xfffaf8f5), Color(0xffd5cdbe)], // Warm ivory / parchment
    ),
    PieceType.empty: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x00000000), Color(0x00000000)], // Empty is transparent
    ),
  };

  // **** BOXES ****
  static const activePlayerIndicator = BoxDecoration();
  static const inactivePlayerIndicator = BoxDecoration();

  // **** ANIMATIONS ****

  static const Duration thinkingFadeDuration = Duration(milliseconds: 500);

  static const pieceFlipDuration = Duration(milliseconds: 500);

  // **** SIZES ****

  static const thinkingSize = 10.0;

  // **** TEXT ****

  static const scoreText = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Georgia',
    fontFamilyFallback: ['serif'],
    color: Color(0xe0ffffff),
    fontStyle: FontStyle.italic,
  );

  static const scoreLabelText = TextStyle(
    fontSize: 20.0,
    fontFamily: 'Georgia',
    fontFamilyFallback: ['serif'],
    color: Color(0xa0ffffff),
    fontStyle: FontStyle.normal,
  );

  static const resultText = TextStyle(
    fontSize: 40.0,
    fontFamily: 'Georgia',
    fontFamilyFallback: ['serif'],
    color: Color(0xe0ffffff),
    fontStyle: FontStyle.italic,
  );

  static const buttonText = TextStyle(
    fontSize: 20.0,
    fontFamily: 'Georgia',
    fontFamilyFallback: ['serif'],
    color: Color(0xe0ffffff),
    fontStyle: FontStyle.italic,
  );
}
