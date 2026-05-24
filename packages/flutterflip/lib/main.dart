// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutterflip_shared/game_board.dart';
import 'bloc/game_bloc.dart';
import 'styling.dart';
import 'thinking_indicator.dart';

/// Main function for the app. Turns off the system overlays and locks portrait
/// orientation for a more game-like UI, and then runs the [Widget] tree.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FlutterFlipApp());
}

/// The App class. Unlike many Flutter apps, this one does not use Material
/// widgets, so there's no [MaterialApp] or [Theme] objects.
class FlutterFlipApp extends StatelessWidget {
  const FlutterFlipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xffffffff), // Mandatory background color.
      onGenerateRoute: (settings) {
        return PageRouteBuilder<dynamic>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => BlocProvider(
            create: (_) => GameBloc()..add(const StartGame()),
            child: const GameScreen(),
          ),
        );
      },
    );
  }
}

/// The [GameScreen] Widget represents the entire game
/// display, from scores to board state and everything in between.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

/// State class for [GameScreen].
class GameScreenState extends State<GameScreen> {
  // Tapping a grid cell dispatches a PlayMove event to the BLoC.
  void _attemptUserMove(BuildContext context, int x, int y) {
    context.read<GameBloc>().add(PlayMove(x, y));
  }

  Widget _buildScoreBox(PieceType player, GameState state) {
    final label = player == PieceType.black ? 'black' : 'white';
    final scoreText = player == PieceType.black
        ? '${state.model.blackScore}'
        : '${state.model.whiteScore}';

    final isActive =
        state.model.player == player && state.status != GameStatus.complete;

    return DecoratedBox(
      decoration: isActive
          ? Styling.activePlayerIndicator
          : Styling.inactivePlayerIndicator,
      child: Column(
        children: <Widget>[
          Text(
            label,
            textAlign: TextAlign.center,
            style: Styling.scoreLabelText,
          ),
          Text(
            scoreText,
            textAlign: TextAlign.center,
            style: Styling.scoreText,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGameBoardDisplay(BuildContext context, GameState state) {
    final rows = <Widget>[];

    for (var y = 0; y < GameBoard.height; y++) {
      final spots = <Widget>[];

      for (var x = 0; x < GameBoard.width; x++) {
        spots.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              gradient: Styling
                  .pieceGradients[state.model.board.getPieceAtLocation(x, y)],
            ),
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: GestureDetector(
                key: ValueKey('cell_${x}_$y'),
                onTap: () {
                  _attemptUserMove(context, x, y);
                },
              ),
            ),
          ),
        );
      }

      rows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: spots,
        ),
      );
    }

    return rows;
  }

  Widget _buildGameResult(BuildContext context, GameState state) {
    final isComplete = state.status == GameStatus.complete;

    return Opacity(
      opacity: isComplete ? 1 : 0,
      child: IgnorePointer(
        ignoring: !isComplete,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.model.gameResultString, style: Styling.resultText),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                context.read<GameBloc>().add(const StartGame());
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xe0ffffff)),
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(15, 5, 15, 9),
                  child: Text('new game', style: Styling.buttonText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds out the Widget tree using the GameState from the BlocBuilder.
  Widget _buildWidgets(BuildContext context, GameState state) {
    return Container(
      padding: const EdgeInsets.only(top: 30.0, left: 15.0, right: 15.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Styling.backgroundStartColor, Styling.backgroundFinishColor],
        ),
      ),
      child: SafeArea(
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildScoreBox(PieceType.black, state),
                  const SizedBox(width: 100),
                  _buildScoreBox(PieceType.white, state),
                ],
              ),
              const SizedBox(height: 20),
              ThinkingIndicator(
                color: Styling.thinkingColor,
                height: Styling.thinkingSize,
                visible: state.status == GameStatus.processing,
              ),
              const SizedBox(height: 20),
              ..._buildGameBoardDisplay(context, state),
              const SizedBox(height: 30),
              _buildGameResult(context, state),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return _buildWidgets(context, state);
      },
    );
  }
}
