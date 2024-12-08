# Export Logic Pro Overdub Takes with Reference Track

This Python script processes Logic Pro project files to export overdubs into separate wav files. The script:
1. Identifies the reference track in the Logic Pro project file.
2. Splits other tracks into takes based on the reference track's length.
3. Exports the takes with consistent naming.

## Requirements

- macOS
- Python 3.7 or higher
- [pydub](https://github.com/jiaaro/pydub) library: Install with `pip install pydub`
- ffmpeg: Install via Homebrew with `brew install ffmpeg`

## Installation

1. Clone this repository:
    ```bash
    git clone https://github.com/<your-username>/logic-takes-export.git
    cd logic-takes-export
    ```
2. Install dependencies:
    ```bash
    pip install pydub
    brew install ffmpeg
    ```

## Usage

### Running the Script
To process Logic Pro project files:
```bash
python export_logic_takes.py <logic_project_1.logicx> [<logic_project_2.logicx> ...] <output_directory>
