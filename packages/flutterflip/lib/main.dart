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

/// A stateful game piece that animates its transition between colors
/// using a 3D Y-axis rotation and perspective projection.
class FlippingPiece extends StatefulWidget {
  final PieceType type;

  const FlippingPiece({super.key, required this.type});

  @override
  State<FlippingPiece> createState() => _FlippingPieceState();
}

class _FlippingPieceState extends State<FlippingPiece>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late PieceType _displayedType;
  PieceType? _targetType;

  @override
  void initState() {
    super.initState();
    _displayedType = widget.type;
    _controller = AnimationController(
      vsync: this,
      duration: Styling.pieceFlipDuration,
    );
  }

  @override
  void didUpdateWidget(FlippingPiece oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      final isFlip =
          (oldWidget.type == PieceType.black &&
              widget.type == PieceType.white) ||
          (oldWidget.type == PieceType.white && widget.type == PieceType.black);

      if (isFlip) {
        _targetType = widget.type;
        _controller.forward(from: 0.0).then((_) {
          if (mounted) {
            setState(() {
              _displayedType = widget.type;
              _targetType = null;
              _controller.reset();
            });
          }
        });
      } else {
        setState(() {
          _displayedType = widget.type;
          _targetType = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_targetType == null) {
      return _buildPiece(_displayedType);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        final angle = val * 3.141592653589793;
        final isFront = val < 0.5;
        final displayType = isFront ? _displayedType : _targetType!;
        final transformAngle = isFront ? angle : angle - 3.141592653589793;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002) // Perspective projection
            ..rotateY(transformAngle),
          alignment: Alignment.center,
          child: _buildPiece(displayType),
        );
      },
    );
  }

  Widget _buildPiece(PieceType type) {
    if (type == PieceType.empty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: Styling.pieceGradients[type],
        boxShadow: const [
          BoxShadow(
            color: Color(0x70000000),
            blurRadius: 4.0,
            offset: Offset(1.0, 3.0),
          ),
          BoxShadow(
            color: Color(0x1affffff),
            blurRadius: 1.0,
            offset: Offset(-1.0, -1.0),
          ),
        ],
      ),
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

    // "Old money" elegant state changes: active glows in gold, inactive is muted parchment grey
    final labelStyle = Styling.scoreLabelText.copyWith(
      color: isActive ? Styling.oldGoldColor : const Color(0xff706a5e),
      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
    );

    final scoreStyle = Styling.scoreText.copyWith(
      color: isActive ? const Color(0xffe6dfd3) : const Color(0xff706a5e),
      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: <Widget>[
          Text(
            label,
            textAlign: TextAlign.center,
            style: labelStyle,
          ),
          const SizedBox(height: 4.0),
          Text(
            scoreText,
            textAlign: TextAlign.center,
            style: scoreStyle,
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
        final pieceType = state.model.board.getPieceAtLocation(x, y);
        final isLegal =
            state.status == GameStatus.readyForPlayer &&
            state.model.board.isLegalMove(x, y, state.model.player);

        spots.add(
          Container(
            margin: const EdgeInsets.all(0.5),
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: const Color(
                0xff143d1a,
              ), // Darker rich felt green cell base
              border: Border.all(
                color: const Color(0xff091a0c),
                width: 0.5,
              ), // Darkest felt grid line
            ),
            child: GestureDetector(
              key: ValueKey('cell_${x}_$y'),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _attemptUserMove(context, x, y);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlippingPiece(type: pieceType),
                  if (pieceType == PieceType.empty && isLegal)
                    Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Styling.oldGoldColor.withValues(alpha: 0.4),
                        border: Border.all(
                          color: Styling.oldGoldColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                ],
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

  Widget _buildHeader(BuildContext context, GameState state) {
    Widget content;
    if (state.status == GameStatus.complete) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(state.model.gameResultString, style: Styling.resultText),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              context.read<GameBloc>().add(const StartGame());
            },
            child: Container(
              decoration: BoxDecoration(
                color: Styling.brownColor,
                border: Border.all(color: Styling.oldGoldColor, width: 2.0),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x60000000),
                    blurRadius: 4.0,
                    offset: Offset(0.0, 2.0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                child: Text(
                  'new game',
                  style: Styling.buttonText.copyWith(
                    color: Styling.oldGoldColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildScoreBox(PieceType.black, state),
          const SizedBox(width: 100),
          _buildScoreBox(PieceType.white, state),
        ],
      );
    }

    return SizedBox(
      height: 120.0,
      child: Center(
        child: content,
      ),
    );
  }

  // Builds out the Widget tree using the GameState from the BlocBuilder.
  Widget _buildWidgets(BuildContext context, GameState state) {
    return Container(
      padding: const EdgeInsets.only(
        top: 30.0,
        bottom: 30.0,
        left: 15.0,
        right: 15.0,
      ),
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
              _buildHeader(context, state),
              const SizedBox(height: 20),
              ThinkingIndicator(
                color: Styling.thinkingColor,
                height: Styling.thinkingSize,
                visible: state.status == GameStatus.processing,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Styling.brownColor, // Wooden frame color
                  border: Border.all(
                    color: Styling.oldGoldColor, // Gold trim
                    width: 3.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(
                        0x90000000,
                      ), // Slightly darker shadow for richer depth
                      blurRadius: 16.0,
                      spreadRadius: 2.0,
                      offset: Offset(0.0, 8.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildGameBoardDisplay(context, state),
                ),
              ),
              const SizedBox(height: 25.0),
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
