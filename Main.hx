import DateTools;
import src.WriteBeatmap;
import captain.Command;
import Std.parseFloat;
import src.SearchBeatmap;
import src.EncodeAudio;
import Console;

class Main {
	static macro function getDefine(key:String):haxe.macro.Expr {
		return macro $v{haxe.macro.Context.definedValue(key)};
	}

	static macro function getBuildTime() {
		return macro $v{DateTools.format(Date.now(), "%Y-%m-%d at %H:%M:%S")};
	}

	static function main() {
		final command = new Command(Sys.args());

		command.name = "osu-beatmod";
		command.options = [
			{
				name: "path",
				shortName: "p",
				description: "Path of the osu! Songs folder.",
				required: true
			},
			{
				name: "beatmap",
				shortName: "b",
				description: "Name of a beatmap to find.",
				required: true
			},
			{
				name: "difficulty",
				shortName: "d",
				description: "Name of the map difficulty.",
				required: true
			},
			{
				name: "bpm",
				shortName: "bpm",
				description: "BPM for the modified beatmap. Required if speed isn't supplied."
			},
			{
				name: "speed",
				shortName: "s",
				description: "Speed multiplier for the modified beatmap. Required if bpm isn't supplied."
			},
			{
				name: "hp",
				shortName: "hp",
				description: "HP drain rate for the modified beatmap."
			},
			{
				name: "cs",
				shortName: "cs",
				description: "Circle size for the modified beatmap."
			},
			{
				name: "od",
				shortName: "od",
				description: "Overall difficulty for the modified beatmap."
			},
			{
				name: "ar",
				shortName: "ar",
				description: "Approach rate for the modified beatmap."
			},
			{
				name: "help",
				shortName: "h",
				boolean: true,
				description: "Display this help text."
			},
			{
				name: "version",
				shortName: "v",
				boolean: true,
				description: "Show the version."
			},
		];
		var beatmap = switch (command.getOption("beatmap")) {
			case Some(value): value;
			case None: "None";
		}

		var difficulty = switch (command.getOption("difficulty")) {
			case Some(value): value;
			case None: "None";
		}

		var bpm = switch (command.getOption("bpm")) {
			case Some(value): value;
			case None: "None";
		}

		var speed = switch (command.getOption("speed")) {
			case Some(value): value;
			case None: "None";
		}

		var hp = switch (command.getOption("hp")) {
			case Some(value): value;
			case None: "None";
		}

		var cs = switch (command.getOption("cs")) {
			case Some(value): value;
			case None: "None";
		}

		var od = switch (command.getOption("od")) {
			case Some(value): value;
			case None: "None";
		}

		var ar = switch (command.getOption("ar")) {
			case Some(value): value;
			case None: "None";
		}

		final path = switch (command.getOption("path")) {
			case Some(value): value;
			case None: "None";
		}

		final displayHelp = switch (command.getOption("help")) {
			case Some(value): true;
			case None: false;
		};

		final displayVersion = switch (command.getOption("version")) {
			case Some(value): true;
			case None: false;
		};

		if (displayHelp) {
			Console.println(command.getInstructions());
			return;
		}
		if (displayVersion) {
			Console.println('${command.name} version ${getDefine("version") == null ? "dev" : getDefine("version")}, built on ${getBuildTime()}');
			return;
		}
		if (path == "None") {
			Console.println(command.getInstructions());
			return;
		}
		if (beatmap == "None") {
			Console.println(command.getInstructions());
			return;
		}
		if (difficulty == "None") {
			Console.println(command.getInstructions());
			return;
		}
		if (bpm == "None" && speed == "None") {
			Console.println(command.getInstructions());
			Console.println("\nYou can't use both --bpm and --speed.");
			return;
		}

		// here all required arguments are fulfilled

		beatmap = beatmap.toLowerCase();
		difficulty = difficulty.toLowerCase();

		var foundBeatmap = searchBeatmap(path, beatmap, difficulty);
		if (foundBeatmap.fail == true) {
			return;
		}

		var targetBPM = 0.0, targetSpeed = 0.0;
		if (bpm != "None" && speed == "None") {
			targetBPM = parseFloat(bpm);
			targetSpeed = targetBPM / foundBeatmap.originalBPM;
		} else if (bpm == "None" && speed != "None") {
			targetBPM = parseFloat(speed) * foundBeatmap.originalBPM;
			targetSpeed = parseFloat(speed);
		}

		Console.println("Beatmap found! Generating the modified beatmap...");

		var encoderResponse = encodeAudio(foundBeatmap.beatmapRootPath, foundBeatmap.audioFilename, targetBPM, targetSpeed);
		if (encoderResponse.fail == true) {
			Console.println("Something went wrong while encoding the audio.");
			return;
		}

		writeBeatmap(foundBeatmap.beatmapFilePath, foundBeatmap.beatmapRootPath, encoderResponse.newAudioFilename, targetBPM, targetSpeed, hp, cs, od, ar);

		Console.println("Done!");
	}
}
