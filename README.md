# osu-beatmod

osu-beatmod is a CLI app allowing you to create modified osu! beatmap difficulties with speed changes (target BPM or target speed multiplier) and properties change (AR, OD, HP, CS). It's like "osu-trainer" but lighter, probably faster and that does not use gosumemory.
Supports Windows and Linux, and probably MacOS but I can't compile for it.

## Installation
* Download the latest osu-beatmod binary for your system in the release page.
* Install ffmpeg globally or copy its binaries in the same folder as osu-beatmod ([recommended ffmpeg build](https://github.com/BtbN/FFmpeg-Builds/releases/tag/latest), use the 5.0 or master gpl version for your platform)

## Usage
Navigate to the directory where osu-beatmod is located.

Windows, using cmd: `osu-beatmod <arguments>`  
Linux, Windows Powershell: `./osu-beatmod <arguments>`

On Windows, you can open Powershell by pressing shift + right clicking on the folder, then choose open in Powershell.

### Arguments

For the beatmap and difficulty arguments, you don't need to type the exact same name, osu-beatmod should find the correct beatmap and difficulty with only the partial name, as long as it does not contain a wrong sequence of characters.

* `--path` / `-p`: Path of the osu! Songs folder (required)
* `--beatmap` / `-b`: Name of a beatmap to find (required)
* `--difficulty` / `-d`: Name of the map difficulty (required)
* `--bpm` / `-bpm`: Target BPM for the modified beatmap (required if --speed isn't supplied)
* `--speed` / `-s`: Speed multiplier for the modified beatmap (required if --bpm isn't supplied)
* `--hp` / `-hp`: HP drain rate for the modified beatmap (optional)
* `--cs` / `-cs`: Circle size for the modified beatmap (optional)
* `--ar` / `-ar`: Approach rate for the modified beatmap (optional)
* `--help` / `-h`: Print the help text
* `--version` / `-v`: Show the version

## Build
You need Haxe (and haxelib) to build the project.
The default compiler target for osu-beatmod is C++. Install `hxcpp` with haxelib.
Download the dependencies listed in the app.hxml file using haxelib (`haxelib install [dependency name]`), and run `haxe compile.hxml`

## TODO
* If multiple beatmaps contain the same difficulty name, maybe add a `--mapper` argument to find the wanted map
* Something to remember the osu! Songs folder path?
* GUI
