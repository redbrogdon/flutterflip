# FlutterFlip Server

A pure Dart server-side package running on Firebase Cloud Functions, providing high-performance move recommendations for Reversi (Othello) using the minimax search algorithm.

## Features

- **Optimal Move Search**: Evaluates the game board and determines the best next move using minimax with alpha-beta pruning.
- **Strict Parameter Validation**: Validates the 64-character board state, active player, and search depth range dynamically.
- **Clamped Search Depth**: Clamps depth values between `1` and `6` to prevent CPU exhaustion and guarantee response times well within Cloud Function limits.
- **HTTP Caching**: Includes optimized caching headers (`cache-control: public, max-age=3600`) since minimax evaluations for a given board, player, and depth are purely functional and side-effect-free.

---

## Prerequisites

Before running the server, ensure you have the following installed:

1. **Dart SDK**: Clean static analysis requires the latest stable version of Dart.
2. **Node.js & npm**: Required to run the Firebase Local Emulator Suite.

---

## Installation & Setup

1. **Install Dart Dependencies**:
   Navigate to the server package directory and retrieve the package dependencies:
   ```bash
   cd packages/flutterflip_server
   dart pub get
   ```

2. **Install Firebase Tools**:
   Ensure dependencies are installed in the root of the monorepo to use the locally locked version of `firebase-tools`:
   ```bash
   cd ../..
   npm install
   ```

---

## Running with the Local Emulator

To spin up the Firebase Functions emulator locally and test your endpoint:

1. **Start the Emulator Suite** (run from the monorepo root directory):
   ```bash
   npx firebase emulators:start
   ```
   *Note: If you have `firebase-tools` installed globally, you can also run `firebase emulators:start` directly.*

2. **Emulator Lifecycle**:
   - The emulator will bootstrap, download necessary dependencies, and execute a code generation pass.
   - The CLI compiles your Dart entry point in `bin/server.dart` via `build_runner` into a self-contained Node.js execution unit.
   - Once completed, the Functions emulator will list the active local routes, usually:
     ```text
     ✔  functions[us-central1-get-move]: http://127.0.0.1:5001/demo-no-project/us-central1/get-move
     ```

---

## API Documentation

### GET `/get-move`

Computes the best next move for the active player on a given board layout.

#### Query Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `board` | `string` | **Yes** | 64-character representation of the board using `.` (empty), `X` (black), and `O` (white). |
| `active` | `string` | **Yes** | The active player: `X` or `O`. |
| `depth` | `int` | No | Search depth (min: `1`, max: `6`). Defaults to `4`. Clamped automatically if out of range. |

#### Example Request

```bash
curl -i "http://127.0.0.1:5001/demo-no-project/us-central1/get-move?active=X&depth=4&board=...........................OX......XO...........................X"
```

#### Example Success Response (`200 OK`)

```json
HTTP/1.1 200 OK
content-type: application/json; charset=utf-8
cache-control: public, max-age=3600
...

{
  "move": [2, 3]
}
```

#### Example Error Response (`400 Bad Request`)

If parameters are missing or invalid:

```json
HTTP/1.1 400 Bad Request
content-type: application/json; charset=utf-8
...

{
  "error": "board must be exactly 64 characters long"
}
```
