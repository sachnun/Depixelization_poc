# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Depix is a proof-of-concept tool for recovering plaintext from pixelized screenshots. It exploits the fact that linear box filters process each block separately, matching pixelized blocks against a search image containing known character patterns (typically a De Bruijn sequence).

## Core Commands

### Running the Main Tool

```bash
# Basic depixelization with gamma-corrected averaging (default)
python3 depix.py \
    -p <path/to/pixelated/image.png> \
    -s <path/to/search/image.png> \
    -o <path/to/output.png>

# Linear averaging (for images pixelized by tools like GIMP)
python3 depix.py \
    -p <path/to/pixelated/image.png> \
    -s <path/to/search/image.png> \
    --averagetype linear \
    --backgroundcolor <r,g,b>
```

### Diagnostic Tools

```bash
# Visualize detected pixel blocks (validates box detection)
python3 tool_show_boxes.py \
    -p <path/to/pixelated/image.png> \
    -s <path/to/search/image.png>

# Generate a pixelated test image
python3 tool_gen_pixelated.py \
    -i <path/to/source/image.png> \
    -o <output.png>
```

## Architecture

### Core Algorithm Flow (depix.py:84-178)

1. **Block Detection**: Identifies same-color rectangles in the pixelated image using `findSameColorSubRectangles()`
2. **Color Filtering**: Removes moot colors (black, white, background) via `removeMootColorRectangles()`
3. **Pattern Matching**: Compares each block against all possible positions in the search image using `findRectangleMatches()`
4. **Geometric Resolution**: Uses geometric relationships between neighboring blocks to resolve ambiguous matches through `findGeometricMatchesForSingleResults()` (runs multiple passes)
5. **Output Generation**: Writes single-match blocks directly and averages multi-match blocks

### Key Modules

**depixlib/functions.py**: Core algorithm implementation
- `findSameColorSubRectangles()`: Detects rectangular blocks of uniform color
- `findRectangleMatches()`: Matches pixelated blocks to search image patterns with support for gamma-corrected or linear RGB averaging
- `findGeometricMatchesForSingleResults()`: Resolves ambiguous matches using spatial relationships
- `srgb2lin()` / `lin2srgb()`: Color space conversion for linear averaging mode

**depixlib/Rectangle.py**: Data structures
- `Rectangle`: Base coordinate/dimension container
- `ColorRectange`: Extends Rectangle with RGB color data
- `RectangleMatch`: Stores matched region coordinates and pixel data

**depixlib/LoadedImage.py**: Image I/O wrapper
- Loads images via PIL and converts to 2D arrays for fast indexed access
- `imageData` structure: `list[list[tuple[int, int, int]]]` indexed as `[x][y]`

**depixlib/helpers.py**: Argument validation utilities

### Critical Implementation Details

- **Averaging Types**: `--averagetype` must match how the original image was pixelized:
  - `gammacorrected` (default): For tools like Greenshot that average gamma-encoded RGB values
  - `linear`: For tools like GIMP that convert to linear sRGB before averaging

- **Box Detection Limitations**: The algorithm relies on precise rectangular cutouts. Irregular crops cause incorrect block detection. Use `tool_show_boxes.py` to validate.

- **Geometric Matching**: The algorithm performs 2 passes of geometric matching (depix.py:144-162) to maximize resolved blocks by comparing spatial relationships.

- **Block Size Tolerance**: If >10 different block sizes (or >1% of image area), warns that recropping may improve results (depix.py:117-122).

## Known Constraints

- Requires integer pixel-level text positioning (sub-pixel rendering breaks matching)
- Needs exact font specifications matching the original screenshot
- Cannot handle additional image compression (corrupts block colors)
- Search image must use identical editor settings as pixelated source

## Development Notes

- The project intentionally avoids pip packaging - install dependencies manually as needed
- `depix_static.py` is a placeholder for a future static block-size version
- Progress logging uses Python's `logging` module at INFO level
