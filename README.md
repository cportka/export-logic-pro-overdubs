# Export Logic Pro Overdubs with Reference Track

This script exports overdubbed takes from Logic Pro project files into clean `.wav` files. It:
1. Detects the reference track.
2. Splits overdubs into takes based on the reference track's length.
3. Names exported files consistently.

## Features

- **Flexible Input**: Accepts individual `.logicx` files or folders containing `.logicx` files.
- **Automatic Virtual Environment**: Sets up a temporary Python virtual environment to manage dependencies.
- **Safe Cleanup**: Removes all temporary files after processing.

## Requirements

- macOS
- Python 3.7+ (installed via Homebrew or your package manager)

## Installation

No manual installation is needed. The script automatically creates a temporary environment.

## Usage

```bash
./run-export-overdubs.sh [options] <output_directory> <logic_project_or_folder_1> [<logic_project_or_folder_2> ...]
