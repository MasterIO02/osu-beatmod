package src;

import sys.io.File;
import Std.parseFloat;
import sys.FileSystem;

function searchBeatmap(path, beatmap, difficulty) {
	var allBeatmaps = FileSystem.readDirectory(path);
	var foundBeatmap = "";
	var foundDifficulty = "";
	var foundBeatmaps = [];
	var foundDifficulties = [];

	var failReturn = {
		fail: true,
		audioFilename: "",
		beatmapRootPath: "",
		beatmapFilePath: "",
		originalBPM: 0.0
	}

	for (file in allBeatmaps) {
		if (StringTools.contains(file.toLowerCase(), beatmap)) {
			foundBeatmaps.push(file);
		}
	}
	// filteredFoundBeatmaps is foundBeatmaps without the beatmaps that does not contain the supplied difficulty
	var filteredFoundBeatmaps = foundBeatmaps.copy();
	var notMatchedFilteredFoundBeatmaps = [];

	function filterDifficulties(directory):Void {
		var beatmapFiles = FileSystem.readDirectory(path + '/${directory}');
		var filteredBeatmapFiles = beatmapFiles.copy();
		for (file in beatmapFiles) {
			if (StringTools.endsWith(file.toLowerCase(), ".osu")) {
				var fileDifficulty = file.split("[")[1];
				fileDifficulty = fileDifficulty.split("]")[0];
				if (StringTools.contains(fileDifficulty.toLowerCase(), difficulty)) {
					foundDifficulties.push(file);
				} else {
					filteredBeatmapFiles.remove(file);
				}
			} else {
				filteredBeatmapFiles.remove(file);
			}
		}

		if (filteredBeatmapFiles.length == 0) {
			filteredFoundBeatmaps.remove(directory);
		}

		notMatchedFilteredFoundBeatmaps = filteredFoundBeatmaps.copy();
	}

	var matchingDifficulties = [];
	function matchDifficulty(directory) {
		var beatmapFiles = FileSystem.readDirectory(path + '/${directory}');
		var filteredBeatmapFiles = beatmapFiles.copy();
		for (file in beatmapFiles) {
			if (StringTools.endsWith(file.toLowerCase(), ".osu")) {
				var fileDifficulty = file.split("[")[1];
				fileDifficulty = fileDifficulty.split("]")[0];
				if (fileDifficulty.toLowerCase() == difficulty) {
					matchingDifficulties.push(file);
				} else {
					filteredBeatmapFiles.remove(file);
				}
			} else {
				filteredBeatmapFiles.remove(file);
			}
		}

		if (filteredBeatmapFiles.length == 0) {
			filteredFoundBeatmaps.remove(directory);
		}
	}

	var filteredFoundDifficulties = "";
	function filterFoundDifficulties() {
		// used to have a nicer output when multiple difficulties were found
		for (file in foundDifficulties) {
			var fileDifficulty = file.split("[")[1];
			fileDifficulty = fileDifficulty.split("]")[0];
			filteredFoundDifficulties += '\n$fileDifficulty';
		}
	}

	if (foundBeatmaps.length > 1) {
		// multiple beatmaps matching
		for (beatmapFolder in foundBeatmaps) {
			filterDifficulties(beatmapFolder);
		}

		if (filteredFoundBeatmaps.length > 1) {
			// Try and match because there's multiple difficulties
			for (beatmapToCheck in filteredFoundBeatmaps) {
				matchDifficulty(beatmapToCheck);
			}

			if (matchingDifficulties.length > 1 || matchingDifficulties.length == 0) {
				filterFoundDifficulties();
				Console.println("Multiple difficulties are matching your query. Please make your query more precise.");
				Console.log('Found difficulties: $filteredFoundDifficulties');
				return failReturn;
			}

			// only 1 difficulty found so we can set the foundDifficulty
			foundDifficulty = matchingDifficulties[0];
		} else {
			if (foundDifficulties.length > 1) {
				for (beatmapToCheck in filteredFoundBeatmaps) {
					matchDifficulty(beatmapToCheck);
				}

				if (matchingDifficulties.length > 1 || matchingDifficulties.length == 0) {
					filterFoundDifficulties();
					Console.println("Multiple difficulties are matching your query. Please make your query more precise.");
					Console.log('Found difficulties: $filteredFoundDifficulties');
					return failReturn;
				}

				foundDifficulty = matchingDifficulties[0];
			} else {
				foundDifficulty = foundDifficulties[0];
			}
		}
		foundBeatmap = filteredFoundBeatmaps[0];
	} else {
		// 1 beatmap matching only
		foundBeatmap = foundBeatmaps[0];
		filterDifficulties(foundBeatmap);

		if (foundDifficulties.length > 1) {
			matchDifficulty(foundBeatmap);

			if (matchingDifficulties.length > 1 || matchingDifficulties.length == 0) {
				filterFoundDifficulties();
				Console.println("Multiple difficulties are matching your query. Please make your query more precise.");
				Console.log('Found difficulties: $filteredFoundDifficulties');
				return failReturn;
			}

			foundDifficulty = matchingDifficulties[0];
		} else {
			foundDifficulty = foundDifficulties[0];
		}
	}

	// beatmap search finished

	if (foundBeatmaps.length == 0) {
		Console.println("No beatmap matches your query.");
		return failReturn;
	}

	if (foundDifficulties.length == 0) {
		Console.println("No beatmap difficulty matches your query.");
		return failReturn;
	}

	var beatmapFilePath = '$path/${foundBeatmap}/${foundDifficulty}';
	var beatmapFile = File.getContent(beatmapFilePath);
	var beatmapLines = beatmapFile.split("\n");

	var audioFilename = "", BPM = 0.0;

	for (line in beatmapLines) {
		if (line.split(",").length == 8) {
			var timingPoint = line.split(",");
			if (parseFloat(timingPoint[1]) < 0 && BPM != 0.0)
				continue;
			BPM = Math.round(1 / parseFloat(timingPoint[1]) * 1000 * 60);
			continue;
		}

		if (StringTools.contains(line, "AudioFilename")) {
			audioFilename = line.split(": ")[1];
			continue;
		}

		if (StringTools.contains(line, "Colours")) {
			break;
		}
	}

	return {
		fail: false,
		audioFilename: audioFilename,
		beatmapRootPath: '$path/${foundBeatmap}',
		beatmapFilePath: beatmapFilePath,
		originalBPM: BPM
	}
}
