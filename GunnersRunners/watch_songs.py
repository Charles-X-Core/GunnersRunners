#!/usr/bin/env python3
"""
GunnersRunners Auto Converter - Background Watcher
===================================================
Monitors the game's songs/ folder and auto-converts MP3s to WAV+JSON.
Run this alongside the game for automatic MP3 import.

Usage:
    python watch_songs.py              # auto-detect songs folder
    python watch_songs.py /path/to/songs  # explicit folder
"""

import os
import sys
import time
import json
import subprocess
from pathlib import Path
from datetime import datetime

if sys.platform == "win32":
    os.system("")

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.stderr.reconfigure(encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).parent.resolve()
CONVERT_SCRIPT = SCRIPT_DIR / "convert_to_wav.py"
if not CONVERT_SCRIPT.exists():
    CONVERT_SCRIPT = SCRIPT_DIR.parent / "convert_to_wav.py"

PYTHON = sys.executable


def find_songs_dir():
    local = os.environ.get("LOCALAPPDATA", "")
    if not local:
        return None
    gr_dir = Path(local) / "GunnersRunners"
    if not gr_dir.exists():
        return None

    direct = gr_dir / "songs"
    if direct.exists():
        return direct

    found = []
    for subdir in gr_dir.iterdir():
        songs = subdir / "songs"
        if songs.exists():
            found.append(songs)
    if found:
        found.sort(key=lambda p: p.stat().st_mtime, reverse=True)
        return found[0]
    return None


def log(msg):
    ts = datetime.now().strftime("%H:%M:%S")
    line = f"[{ts}] {msg}"
    print(line, flush=True)


def convert_file(mp3_path, songs_dir):
    log(f"Converting: {mp3_path.name}")
    try:
        cmd = [
            PYTHON, str(CONVERT_SCRIPT),
            str(mp3_path),
            "-o", str(songs_dir)
        ]
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=300,
            encoding="utf-8", errors="replace",
            cwd=str(SCRIPT_DIR)
        )
        wav_path = songs_dir / (mp3_path.stem + ".wav")
        json_path = songs_dir / (mp3_path.stem + ".json")
        if wav_path.exists() and json_path.exists():
            log(f"  OK: {mp3_path.stem} ready")
            return True
        elif wav_path.exists():
            log(f"  WAV created but JSON missing - analyzing...")
            cmd2 = [
                PYTHON, str(CONVERT_SCRIPT),
                str(wav_path),
                "-o", str(songs_dir),
                "--no-convert"
            ]
            subprocess.run(
                cmd2, capture_output=True, text=True, timeout=300,
                encoding="utf-8", errors="replace",
                cwd=str(SCRIPT_DIR)
            )
            if json_path.exists():
                log(f"  OK: {mp3_path.stem} ready (analysis done)")
                return True
            log(f"  WARNING: Analysis failed for {mp3_path.stem}")
            return False
        else:
            log(f"  FAILED: {mp3_path.stem}")
            if result.stderr:
                log(f"  Error: {result.stderr[:200]}")
            return False
    except subprocess.TimeoutExpired:
        log(f"  TIMEOUT: Conversion took too long for {mp3_path.name}")
        return False
    except Exception as e:
        log(f"  ERROR: {e}")
        return False


def analyze_wav_only(wav_path, songs_dir):
    log(f"Analyzing: {wav_path.name}")
    try:
        cmd = [
            PYTHON, str(CONVERT_SCRIPT),
            str(wav_path),
            "-o", str(songs_dir),
            "--no-convert"
        ]
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=300,
            encoding="utf-8", errors="replace",
            cwd=str(SCRIPT_DIR)
        )
        json_path = songs_dir / (wav_path.stem + ".json")
        if json_path.exists():
            log(f"  OK: {wav_path.stem} analyzed")
            return True
        else:
            log(f"  FAILED: {wav_path.stem}")
            if result.stderr:
                log(f"  Error: {result.stderr[:200]}")
            return False
    except subprocess.TimeoutExpired:
        log(f"  TIMEOUT: Analysis took too long for {wav_path.name}")
        return False
    except Exception as e:
        log(f"  ERROR: {e}")
        return False


def scan_and_convert(songs_dir):
    converted = 0

    for mp3 in songs_dir.glob("*.mp3"):
        wav = songs_dir / (mp3.stem + ".wav")
        json_f = songs_dir / (mp3.stem + ".json")
        if not wav.exists() or not json_f.exists():
            if convert_file(mp3, songs_dir):
                converted += 1
            time.sleep(0.5)

    for wav in songs_dir.glob("*.wav"):
        json_f = songs_dir / (wav.stem + ".json")
        if not json_f.exists():
            if analyze_wav_only(wav, songs_dir):
                converted += 1
            time.sleep(0.5)

    return converted


def main():
    print("=" * 50)
    print("GunnersRunners Auto Converter")
    print("=" * 50)
    print()

    songs_dir = None

    if len(sys.argv) > 1:
        candidate = Path(sys.argv[1])
        if candidate.exists() and candidate.is_dir():
            songs_dir = candidate

    if songs_dir is None:
        songs_dir = find_songs_dir()

    if songs_dir is None:
        print("ERROR: Could not find songs/ folder.")
        print("Usage: python watch_songs.py /path/to/songs")
        sys.exit(1)

    log(f"Watching: {songs_dir}")
    log(f"Converter: {CONVERT_SCRIPT}")
    log(f"Python: {PYTHON}")
    log("Press Ctrl+C to stop")
    print()

    scan_and_convert(songs_dir)

    try:
        while True:
            time.sleep(3)
            scan_and_convert(songs_dir)
    except KeyboardInterrupt:
        print()
        log("Stopped.")


if __name__ == "__main__":
    main()
