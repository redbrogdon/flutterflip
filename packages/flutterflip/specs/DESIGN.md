# FlutterFlip App Design Specification

This document details the visual style, user interface guidelines, typography, and animation design for the FlutterFlip mobile and web application.

## 1. Visual Theme & Look and Feel

FlutterFlip utilizes a clean, modern aesthetic with rich gradients, high-contrast UI elements, and fluid animations. Instead of standard solid-color backgrounds, the application adopts a vibrant gradient to create depth.

The application intentionally bypasses Flutter's default Material Design widget set (e.g. `MaterialApp`, `Theme`, `AppBar`) in favor of a lean, custom layout styled via a static `Styling` library. This design choice results in a custom-tailored game interface that is lightweight and highly focused.

---

## 2. Color Palette & Gradients

The colors are defined as static constants in [styling.dart](file:///Users/redbrogdon/source/flutterflip/packages/flutterflip/lib/styling.dart) and are categorized below:

### 2.1 Background
The main application background is a linear gradient running from top-left to bottom-right:
* **Start Color**: Light Blue (`Color(0xb000bfff)`)
* **End Color**: Vibrant Magenta/Purple (`Color(0xb0ff00ee)`)

### 2.2 Game Pieces & Board Cells
Pieces render using circular forms filled with multi-color linear gradients:
* **Black Piece**: Gradient from `Color(0xff101010)` to `Color(0xff303030)`
* **White Piece**: Gradient from `Color(0xffffffff)` to `Color(0xffe0e0e0)`
* **Empty Cell / Move Indicator**: Semi-transparent white gradient from `Color(0x60ffffff)` to `Color(0x40ffffff)`

### 2.3 Other Elements
* **Thinking Indicator**: Semi-transparent white (`Color(0xa0ffffff)`)

---

## 3. Typography

The app imports and configures the **Roboto** font family (specifically using the `Roboto-Thin.ttf` and `Roboto-ThinItalic.ttf` styles), which is configured in [pubspec.yaml](file:///Users/redbrogdon/source/flutterflip/packages/flutterflip/pubspec.yaml).

| Text Element | Size (pt) | Style | Color | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **Score Value** | `50.0` | Italic | `Color(0xe0ffffff)` | Large numeric score display |
| **Score Label** | `20.0` | Normal | `Color(0xa0ffffff)` | Label text ("black" / "white") |
| **Result Title** | `40.0` | Italic | `Color(0xe0ffffff)` | End-of-game victory/draw message |
| **Button Text** | `20.0` | Italic | `Color(0xe0ffffff)` | "new game" button text |

---

## 4. Animations & Micro-interactions

Animations are critical to providing visual feedback to the player during game states:

* **Piece Flipping**: Flip animations take exactly **300ms** to execute, providing immediate tactile response when a piece is captured.
* **Thinking State**: The CPU's processing state is animated via a glowing fade animation (using `ThinkingIndicator`) with a duration of **500ms**.
* **Active Turn Indicator**: The current active player is indicated by a white bottom-border underline (`Color(0xffffffff)`), while the inactive player is underlined with a transparent border (`Color(0x00000000)`).
