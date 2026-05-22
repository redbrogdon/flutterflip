# FlutterFlip Server API Specification

This document serves as the formal specification and Product Requirements Document (PRD) for the `flutterflip_server` package. It defines the service's API endpoints, expected request inputs, response formats under common scenarios, and rules for client integrations.

## 1. Overview

The `flutterflip_server` is a stateless, high-performance microservice designed to run on **Firebase Cloud Functions**. It provides optimal move recommendations for Reversi games using a minimax search algorithm with alpha-beta pruning.

### Key Characteristics
* **Statelessness**: The service does not store board state, game history, or user data. Each request is evaluated in isolation.
* **Deterministic Output**: For any given board configuration, active player, and search depth, the output move is strictly deterministic.
* **Aggressive Caching**: Because the minimax calculation is side-effect-free and pure, responses include optimized HTTP caching headers to minimize compute load and latency for recurrent board queries.
* **Timeout Defense**: The server dynamically clamps computation depth to ensure execution completes well within Cloud Function limits.

## 2. API Endpoints

### 2.1 Get Next Move
Computes the optimal Reversi move for a given board layout.

* **Path**: `/get-move`
* **HTTP Method**: `GET`
* **Headers**:
  * `Accept: application/json`

#### Query Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `board` | `String` | **Yes** | A **64-character** flat string representing the 8x8 Reversi board state (row-by-row, top-to-bottom, left-to-right). |
| `player` | `String` | **Yes** | The active player whose turn it is to move. Must be exactly `black` or `white` (case-insensitive). |
| `depth` | `Integer` | No | The search tree depth representing the number of plies (turns ahead) to look. Defaults to `4`. Clamped internally between `1` and `6` (inclusive). |

## 3. Data Representation

### 3.1 Board Layout & Coordinate Mapping
Reversi is played on an `8 x 8` grid (64 squares total). The `board` string parameter uses the following character mapping:
* `.` (period) : Empty cell
* `B` or `b` : Black piece
* `W` or `w` : White piece

The 64-character string maps to the grid in **row-major order** (row by row, starting from the top-left corner).

## 4. Algorithmic Rules & Edge Cases

### 4.1 Search Depth Clamping
To prevent CPU starvation and guarantee response times within Firebase Cloud Functions execution limits, the search depth parameter is subject to server-side clamping:
* If `depth < 1`, the server will evaluate with depth `1`.
* If `depth > 6`, the server will evaluate with depth `6`.
* Out-of-bounds search requests are **not** rejected with a `400 Bad Request`; instead, the server processes them at the nearest boundary and indicates the actual computed depth in the response metadata (`depth` field).

### 4.2 Handling "Pass" Scenarios (No Moves Available)
In Reversi, if a player has no legal moves available, they must **pass** their turn.
* If the active player has at least one valid move, the server returns the coordinates of highest-scoring chosen move.
* If the active player has **no legal moves** on the current board state, the server returns `move: null`.
* If the game has ended (neither player has legal moves, or the board is full), the server returns `move: null`.

## 5. Protocol Responses & Examples

The service responds with a JSON object containing a "move" property. If no move was found, the "move" property will be null. If a move was found, the "move" property will be an object with "x" and "y" properties representing the coordinates of the move. The "x" property represents the column index (0-7) and the "y" property represents the row index (0-7).

### 5.1 Success Response (`200 OK`)
Returned when the input parameters are successfully parsed and validated, and a move is calculated.

#### Response Headers
* `Content-Type: application/json`
* `Cache-Control: public, max-age=3600` (Responses are cacheable for 1 hour to optimize client-side performance).

#### Scenario A: Optimal Move Found
* **Request URL**: `GET /get-move?player=black&depth=4&board=...........................BW......WB...........................`
* **Response Body**:
```json
{
  "move": {
    "x": 2,
    "y": 3
  }
}
```

#### Scenario B: Player Must Pass (No Moves Available)
* **Request URL**: `GET /get-move?player=white&depth=4&board=BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBW.`
* **Response Body**:
```json
{
  "move": null
}
```

## 6. Error & Failure States

### 6.1 Validation Failure (`400 Bad Request`)
Returned when request parameters are missing, malformed, or contain invalid choices.

#### Scenario A: Invalid Board Length
* **Cause**: `board` query parameter length is not exactly 64 characters.
* **Response Body**:
```text
Invalid or missing "board" parameter. Must be exactly 64 characters.
```

#### Scenario B: Invalid/Missing Player
* **Cause**: `player` parameter is missing or is not equal to `"black"` or `"white"`.
* **Response Body**:
```text
Invalid or missing "player" parameter. Must be "black" or "white".
```

### 6.2 HTTP Method Not Allowed (`405 Method Not Allowed`)
Returned when an HTTP verb other than `GET` is used to query the endpoint.
* **Cause**: Client issued a `POST`, `PUT`, `DELETE`, etc.
* **Response Body**:
```text
Method Not Allowed
```

### 6.3 Server Error (`500 Internal Server Error`)
Returned when an unexpected runtime exception is encountered within the minimax solver or request parser.
* **Response Body**:
```text
Error processing request: <error details>
```

## 7. Client Integration Best Practices

1. **Accept and Handle Null Moves**: Client UIs must be prepared to handle `move: null` gracefully. It represents a mandatory "Pass" turn under standard Reversi rules.
2. **Handle Auto-Clamped Depths**: If requesting variable difficulties based on depth, be aware that values exceeding `6` will be solved using a maximum depth of `6`. The `depth` field in the response represents the actual search depth utilized.
3. **Respect Caching**: Mobile and web clients should utilize standard HTTP caching mechanisms. Identical requests made within the cache duration (`max-age=3600`) can be resolved instantly from cache to save battery and network bandwidth.
4. **Coordinate Mapping**: When applying the returned move, remember that `x` represents the horizontal column (0 = leftmost, 7 = rightmost) and `y` represents the vertical row (0 = topmost, 7 = bottommost).
