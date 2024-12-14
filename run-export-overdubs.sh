//TODO: DOES NOT WORK FOR PROCESSING GETTING AND ITERATING THROUGH ALL THE LOGICX FILES

#!/bin/bash

# Exit immediately on errors
set -e

# Constants
SCRIPT="export-overdubs.py"

# Function to print usage
print_usage() {
    echo "Usage: ./run-export-overdubs.sh [options] <logic_project_or_folder_1> [<logic_project_or_folder_2> ...]"
    echo ""
    echo "Options:"
    echo "  -o <output_directory>     Specify the directory where exported audio files will be saved."
    echo "  -h, --help                Show this help message and exit."
    echo ""
    echo "Arguments:"
    echo "  <logic_project_or_folder> Logic Pro project file (.logicx) or a folder containing Logic Pro files."
    echo ""
    echo "Examples:"
    echo "  ./run-export-overdubs.sh -o ./Output ./MyProject.logicx"
    echo "  ./run-export-overdubs.sh ./ProjectsFolder"
    echo "  ./run-export-overdubs.sh"
    echo "If no output directory is specified, the current directory will be used by default."
}

# Function to find Python executable
find_python() {
    if command -v python3 &>/dev/null; then
        echo "python3"
    elif command -v python &>/dev/null; then
        echo "python"
    else
        echo ""
    fi
}

# Parse options and arguments
OUTPUT_DIR="$(pwd)"  # Default to current directory
LOGIC_INPUTS=()

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -o)
            shift
            if [ -z "$1" ]; then
                echo "Error: -o option requires an argument."
                exit 1
            fi
            OUTPUT_DIR="$1"
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            LOGIC_INPUTS+=("$1")
            ;;
    esac
    shift
done

# If no arguments are provided, print usage
if [ "${#LOGIC_INPUTS[@]}" -eq 0 ]; then
    print_usage
    exit 1
fi

# Validate Python installation
PYTHON_EXECUTABLE=$(find_python)
if [ -z "$PYTHON_EXECUTABLE" ]; then
    echo "Python 3 is not installed. Please install it using your package manager."
    exit 1
fi

# Ensure the required Python script exists
if [ ! -f "$SCRIPT" ]; then
    echo "Script $SCRIPT not found in the current directory."
    exit 1
fi

# Collect all .logicx files from provided inputs
LOGIC_FILES=()
for input in "${LOGIC_INPUTS[@]}"; do
    # Expand input path and check if it exists
    RESOLVED_PATH=$(eval echo "$input")
    if [ ! -e "$RESOLVED_PATH" ]; then
        echo "Warning: Skipping invalid input: $input"
        continue
    fi

    if [ -f "$RESOLVED_PATH" ] && [[ "$RESOLVED_PATH" == *.logicx ]]; then
        LOGIC_FILES+=("$RESOLVED_PATH")
    elif [ -d "$RESOLVED_PATH" ]; then
        # Find all .logicx files in the directory
        while IFS= read -r -d '' file; do
            LOGIC_FILES+=("$file")
        done < <(find "$RESOLVED_PATH" -type f -name "*.logicx" -print0)
    else
        echo "Warning: Skipping unsupported input: $input"
    fi
done

if [ ${#LOGIC_FILES[@]} -eq 0 ]; then
    echo "No Logic Pro project files (.logicx) found in the provided inputs."
    exit 1
fi

# Create a temporary virtual environment
VENV_DIR=$(mktemp -d)
echo "Creating temporary virtual environment in $VENV_DIR"
"$PYTHON_EXECUTABLE" -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# Install required dependencies
pip install --quiet pydub

# Run the Python script for each Logic Pro file
echo "Running the overdub export script..."
for logic_file in "${LOGIC_FILES[@]}"; do
    echo "Processing $logic_file..."
    python "$SCRIPT" "$logic_file" "$OUTPUT_DIR"
done

# Cleanup the virtual environment
deactivate
echo "Cleaning up virtual environment..."
rm -rf "$VENV_DIR"

echo "Export process completed successfully. Files saved to: $OUTPUT_DIR"
