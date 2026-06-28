# FlutterFlip App Design Specification

This document details the visual style, user interface guidelines, typography, and animation design for the classic, premium "old money" board-game style of FlutterFlip.

## 1. Visual Theme & Look and Feel

FlutterFlip utilizes a warm, tactile, high-end board game aesthetic. The layout invokes the feeling of playing on a physical table in a historic private club:
*   **Green Felt Table**: The overall screen mimics a deep, rich British racing green felt card table.
*   **Wooden Frame Board**: The game board itself is encapsulated in a rich mahogany/walnut wood-textured frame with a burnished old gold trim.
*   **Tactile Board Grid**: The grid cells are styled as rich moss green felt squares, outlined with dark forest green lines.
*   **Round 3D Pieces**: The game pieces are circular, styled with subtle light reflections, 3D radial gradients, and soft drop shadows to simulate real plastic or wooden Reversi discs.

---

## 2. Color Palette & Gradients

The colors are defined in [styling.dart](file:///Users/redbrogdon/source/flutterflip/packages/flutterflip/lib/styling.dart):

### 2.1 Background & Theme
*   **Felt Background Gradient**: Linear gradient from Deep British Racing Green (`Color(0xff0d2e13)`) to Darkest Shadow Green (`Color(0xff051406)`).
*   **Wood Brown (Frame/Accents)**: Mahogany Brown (`#2b140b`, `Color(0xff2b140b)`), representing polished dark wood.
*   **Old Gold (Trim/Active Indicators)**: Burnished Old Gold (`#b89730`, `Color(0xffb89730)`), representing a soft, antique metallic gold.

### 2.2 Game Pieces
*   **Black Piece**: 3D linear gradient from ebony/obsidian black (`Color(0xff0a0a0a)`) to charcoal (`Color(0xff242424)`), with bottom-right shadow offsets and light highlights.
*   **White Piece**: 3D linear gradient from warm ivory (`Color(0xfffaf8f5)`) to parchment/aged bone (`Color(0xffd5cdbe)`), with soft shadows.
*   **Legal Move Indicator**: A hollow, semi-transparent circle/ring in `oldGoldColor` to guide the player without cluttering the board.

---

## 3. Typography

To move away from modern, sterile fonts, the application utilizes a classic serif typography system:
*   **Primary Font Family**: **`Georgia`** (with a fallback to standard system **`serif`**).
*   This family provides an organic, literary look suited for a high-quality physical game simulation.

| Text Element | Size (pt) | Style | Color | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **Score Value** | `50.0` | Italic | `Color(0xe0ffffff)` / Muted Parchment | Large numeric score |
| **Score Label** | `20.0` | Normal | `Color(0xa0ffffff)` / Muted Parchment | Labels ("black" / "white") |
| **Result Title** | `40.0` | Italic | `Color(0xe0ffffff)` | Victory/draw banner |
| **Button Text** | `20.0` | Italic | `Color(0xe0ffffff)` | "new game" button text |

---

## 4. Animations & Micro-interactions

Animations mimic real physical interactions to build immersion:

*   **3D Piece Flipping**: Captured pieces undergo a 3D Y-axis rotation over **500ms** utilizing perspective projection. The piece rotates $180^\circ$, switching color mid-flip at the $90^\circ$ vertical mark to simulate a physical piece being turned over.
*   **Thinking State**: Alternate gold and brown circular peg indicators expanding and contracting horizontally (duration **500ms**).
*   **Active Turn Indicator**: Highlighting the active player's name and score in bold **Burnished Old Gold** (`Color(0xffb89730)`) and full opacity, while the inactive player's scores and labels are shown in muted parchment gray (`Color(0xff8c8475)`). Underline borders are removed.
