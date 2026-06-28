# FlutterFlip App Usage & Gameplay Specification

This document describes the user experience, functionality, gameplay rules, and platform compatibility of the FlutterFlip application.

## 1. Game Overview (Reversi / Othello Rules)

Reversi is a strategy board game for two players, played on an 8x8 ungrid. 
*   **Players**: Black (Human) and White (CPU).
*   **Starting State**: The board begins with 4 pieces placed in the center: 2 black and 2 white diagonally adjacent.
*   **Gameplay Cycle**:
    *   Players take turns placing a piece of their color on the board.
    *   A legal move must trap one or more opponent pieces in a straight line (horizontally, vertically, or diagonally) between the newly placed piece and another piece of the current player's color.
    *   All trapped opponent pieces are flipped to the current player's color.
    *   If a player has no legal moves, their turn is passed.
    *   The game ends when neither player has a legal move (e.g. board is full, or one player's pieces are completely wiped out).
    *   The player with the most pieces at the end wins.

---

## 2. User Experience & Game Flow

### 2.1 Starting a New Game
Upon launch, the application configures the board with the four center pieces. The scores initialize to `2` for both players. The human player (Black) takes the first turn.

### 2.2 Making a Move
*   The human player taps any cell on the board.
*   If the tapped cell is a legal move, the piece is placed and any trapped CPU pieces are flipped.
*   If the move is illegal, the tap is ignored.

### 2.3 CPU Turn & Thinking Flow
Once the human player completes a turn, the game state switches to `processing` (CPU's turn):
*   A glowing, animated **thinking indicator** appears below the scores.
*   The CPU calculates the best move using a minimax solver.
*   **Natural Gameplay Delay**: To prevent the CPU from playing moves instantly (which can be jarring and feel unnatural to the user), the system ensures a minimum **1-second thinking delay**.
*   **Forced Move Optimization**: If the CPU has exactly one legal move (a forced move), the application optimizes processing by skipping the minimax solver (avoiding HTTP requests and isolate spawns) and simply executing the move after the 1-second delay.

### 2.4 Passing Turns
If a player has no legal moves, their turn is passed:
*   If the human player has no moves, the CPU immediately takes its turn.
*   If the CPU has no moves, it passes the turn back to the human.

### 2.5 Game Over & Reset
When the game ends:
*   A result banner displays the outcome (e.g., "black wins", "white wins", or "draw").
*   A **"new game"** button appears.
*   Tapping the button resets the board and starts a new match.

---

## 3. Supported Platforms

FlutterFlip is designed using highly portable, platform-agnostic Flutter constructs. By avoiding custom Native SDK bindings, the application is compatible with:

*   **Mobile**: Android, iOS
*   **Web**: Modern browsers (compiled via Flutter Web)
*   **Desktop**: macOS, Windows, Linux
