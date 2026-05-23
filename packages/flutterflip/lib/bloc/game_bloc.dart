import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterflip_shared/game_board.dart';
import 'package:flutterflip_shared/game_model.dart';
import '../services/move_finder_service.dart';

/// Represents the current phase of the Reversi match.
enum GameStatus {
  readyForPlayer, // Waiting for the human player (Black) to choose a move.
  processing,     // CPU (White) is computing its optimal next move.
  complete,       // Match finished (neither player has valid moves).
}

/// The unified game state containing the board model, status, and optional errors.
class GameState {
  final GameModel model;
  final GameStatus status;
  final String? errorMessage;

  const GameState({
    required this.model,
    required this.status,
    this.errorMessage,
  });

  GameState copyWith({
    GameModel? model,
    GameStatus? status,
    String? errorMessage,
  }) {
    return GameState(
      model: model ?? this.model,
      status: status ?? this.status,
      errorMessage: errorMessage, // We reset the error message on copy if not explicitly passed
    );
  }
}

/// Sealed base class for all Reversi game events.
sealed class GameEvent {
  const GameEvent();
}

/// Dispatched to reset the game to its standard starting position.
class StartGame extends GameEvent {
  const StartGame();
}

/// Dispatched when the human player plays a move at coordinate (x, y).
class PlayMove extends GameEvent {
  final int x;
  final int y;

  const PlayMove(this.x, this.y);
}

/// Internal event dispatched to trigger the CPU's move evaluation.
class FetchCpuMove extends GameEvent {
  const FetchCpuMove();
}

/// The central game state machine implementing Reversi rules.
class GameBloc extends Bloc<GameEvent, GameState> {
  final MoveFinderService _finderService;

  GameBloc({MoveFinderService? finderService})
      : _finderService = finderService ?? MoveFinderService(),
        super(GameState(
          model: GameModel(board: GameBoard(), player: PieceType.black),
          status: GameStatus.readyForPlayer,
        )) {
    on<StartGame>(_onStartGame);
    on<PlayMove>(_onPlayMove);
    on<FetchCpuMove>(_onFetchCpuMove);
  }

  void _onStartGame(StartGame event, Emitter<GameState> emit) {
    final startingBoard = GameBoard();
    final startingModel = GameModel(board: startingBoard, player: PieceType.black);
    emit(GameState(
      model: startingModel,
      status: GameStatus.readyForPlayer,
    ));
  }

  GameState _processNextTurn(GameModel updatedModel) {
    if (updatedModel.gameIsOver) {
      return GameState(
        model: updatedModel,
        status: GameStatus.complete,
      );
    }

    if (updatedModel.player == PieceType.white) {
      return GameState(
        model: updatedModel,
        status: GameStatus.processing,
      );
    }

    return GameState(
      model: updatedModel,
      status: GameStatus.readyForPlayer,
    );
  }

  Future<void> _onPlayMove(PlayMove event, Emitter<GameState> emit) async {
    if (state.status != GameStatus.readyForPlayer) return;
    if (state.model.player != PieceType.black) return;

    if (!state.model.board.isLegalMove(event.x, event.y, state.model.player)) {
      return; // Ignore illegal moves
    }

    try {
      final updatedModel = state.model.updateForMove(event.x, event.y);
      final nextState = _processNextTurn(updatedModel);
      emit(nextState);

      if (nextState.status == GameStatus.processing) {
        add(const FetchCpuMove());
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update move: $e',
      ));
    }
  }

  Future<void> _onFetchCpuMove(FetchCpuMove event, Emitter<GameState> emit) async {
    if (state.status != GameStatus.processing) return;
    if (state.model.player != PieceType.white) return;

    try {
      final cpuMoves = state.model.board.getMovesForPlayer(PieceType.white);
      Position? move;

      if (cpuMoves.length == 1) {
        // Optimization: CPU has only one legal move (forced move).
        // Delay for exactly 1 second to let thinking animation flow naturally,
        // without making any HTTP request or spawning background isolates.
        await Future<void>.delayed(const Duration(seconds: 1));
        move = cpuMoves.first;
      } else {
        // CPU has multiple moves: query finder while concurrently maintaining
        // the 1-second animation delay.
        final results = await Future.wait([
          _finderService.findNextMove(state.model.board, state.model.player, 5),
          Future<void>.delayed(const Duration(seconds: 1)),
        ]);
        move = results[0] as Position?;
      }

      if (move != null) {
        final updatedModel = state.model.updateForMove(move.x, move.y);
        final nextState = _processNextTurn(updatedModel);
        emit(nextState);

        if (nextState.status == GameStatus.processing) {
          add(const FetchCpuMove());
        }
      } else {
        // Fallback for null moves (force pass back to human player if valid)
        final nextPlayer = state.model.board.getMovesForPlayer(PieceType.black).isNotEmpty
            ? PieceType.black
            : PieceType.empty;
        final updatedModel = GameModel(board: state.model.board, player: nextPlayer);

        emit(state.copyWith(
          model: updatedModel,
          status: updatedModel.gameIsOver ? GameStatus.complete : GameStatus.readyForPlayer,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'CPU Finder error: $e',
        status: GameStatus.readyForPlayer, // Allow manual player recovery
      ));
    }
  }
}
