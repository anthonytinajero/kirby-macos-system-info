Kirby macOS System Info

A lightweight, Kirby-inspired system information CLI for macOS, built using Bash.

Features a custom Kirby ASCII design, pastel pink-and-white styling, real-time system information, and a classic rainbow terminal color palette.

Preview

screenshotk.png

Features

   Custom white Kirby ASCII art

   Pastel pink system information labels

   Automatic macOS hardware detection

   CPU, GPU, OS, kernel, and shell information

   System uptime

   Memory and disk usage with progress bars

   Two-row rainbow terminal color palette

   Lightweight Bash implementation

Requirements

macOS

Bash

A terminal supporting ANSI colors and Unicode characters

No additional software dependencies are required beyond standard macOS command-line utilities.

Installation

1. Clone the repository

git clone https://github.com/YOUR_USERNAME/kirby-macos-system-info.git

2. Navigate into the project

cd kirby-macos-system-info

3. Run the script

bash system-info.sh

The script automatically retrieves system information from the Mac on which it is executed.

Customization

The appearance can be customized directly in system-info.sh.

Change the pink accent color:

PINK=$'\033[38;2;255;183;213m'

Default color: #FFB7D5 (Kirby Pink)

Change the ASCII art:

Find the ART section of the script and replace the existing artwork with your preferred Unicode or ASCII design.

Change the progress bars:

Adjust the width variable inside the progress_bar() function.

How It Works

The script uses built-in macOS command-line utilities to retrieve system information, including:

sw_vers — macOS version

sysctl — CPU, hardware model, and memory

system_profiler — GPU and Apple Silicon information

vm_stat — Memory usage

df — Disk usage

uptime — System uptime

ANSI escape sequences provide the colors and terminal formatting.

Notes

Designed specifically for macOS.

System information varies depending on the Mac.

Terminal appearance may vary depending on font and window size.

Running the script does not modify shell configuration files.
