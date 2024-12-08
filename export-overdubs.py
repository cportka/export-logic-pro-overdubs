import os
import sys
from pydub import AudioSegment
from pydub.exceptions import CouldntDecodeError

def is_reference_track(file_name, project_name):
    """
    Determines if a file is the reference track based on its filename.
    Looks for filenames containing the project name or key descriptors like 'COMP' or 'ROUGH'.
    """
    reference_keywords = ['COMP', 'ROUGH', project_name.upper()]
    return any(keyword in file_name.upper() for keyword in reference_keywords)

def get_audio_length(file_path):
    """Returns the duration of the audio file in milliseconds."""
    try:
        audio = AudioSegment.from_file(file_path)
        return len(audio)
    except CouldntDecodeError:
        print(f"Could not decode file: {file_path}")
        return None

def split_takes_by_length(file_path, ref_length, output_dir, base_name):
    """
    Splits a multi-take audio file into separate takes based on the reference length.
    """
    try:
        audio = AudioSegment.from_file(file_path)
        total_length = len(audio)
        num_takes = total_length // ref_length

        if num_takes < 1:
            print(f"File {file_path} is shorter than reference. Skipping.")
            return

        for i in range(num_takes):
            start = i * ref_length
            end = start + ref_length
            take = audio[start:end]
            output_path = os.path.join(output_dir, f"{base_name}_Take{i + 1}.wav")
            take.export(output_path, format="wav")
            print(f"Exported: {output_path}")
    except CouldntDecodeError:
        print(f"Could not decode file: {file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

def export_logic_tracks(logic_file_path, output_dir):
    """
    Processes a Logic project file, identifies the reference track, and splits
    other tracks into takes based on the reference track's length.
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Define paths within the Logic project package
    media_dir = os.path.join(logic_file_path, "Media")
    if not os.path.exists(media_dir):
        print(f"Media folder not found in {logic_file_path}. Are you sure this is a valid Logic project file?")
        return

    project_name = os.path.basename(logic_file_path).replace(".logicx", "")

    # Step 1: Identify reference track
    reference_track = None
    ref_length = None

    for file in os.listdir(media_dir):
        if file.lower().endswith(('.aif', '.aiff', '.wav', '.mp3')) and is_reference_track(file, project_name):
            reference_track = os.path.join(media_dir, file)
            ref_length = get_audio_length(reference_track)
            print(f"Reference track: {reference_track}, Length: {ref_length} ms")
            break

    if not reference_track or not ref_length:
        print(f"Could not find a reference track in {logic_file_path}. Ensure the project is structured correctly.")
        return

    # Step 2: Process other tracks
    for root, _, files in os.walk(media_dir):
        for file in files:
            if file.lower().endswith(('.aif', '.aiff', '.wav')) and file != os.path.basename(reference_track):
                file_path = os.path.join(root, file)
                base_name = f"{os.path.basename(logic_file_path).replace('.logicx', '')}_{os.path.splitext(file)[0]}"
                split_takes_by_length(file_path, ref_length, output_dir, base_name)

def print_usage():
    """Prints usage instructions for the script."""
    print("""
    Usage:
        python export_logic_takes.py <logic_project_1.logicx> [<logic_project_2.logicx> ...] <output_directory>
    
    Example:
        python export_logic_takes.py MySong.logicx AnotherSong.logicx /path/to/output
    
    This script processes Logic Pro project files to export overdub takes.
    Ensure the Logic project files are valid and structured correctly.
    """)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print_usage()
        sys.exit(1)

    # Extract file paths and output directory
    *logic_files, output_dir = sys.argv[1:]

    for logic_file_path in logic_files:
        if not os.path.exists(logic_file_path):
            print(f"Logic project file not found: {logic_file_path}")
            continue

        export_logic_tracks(logic_file_path, output_dir)
